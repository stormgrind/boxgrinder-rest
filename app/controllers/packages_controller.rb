require 'torquebox/queues'

class PackagesController < BaseController
  include PackagesHelper
  include ImagesHelper

  layout 'actions'

  before_filter :load_package, :except => [ :create, :index ]
  before_filter :load_image, :only => [ :create ]
  before_filter :validate_image, :only => [ :create]

  def index
    @packages = Package.all
    render_general( @packages )
  end

  def show
    respond_to do |format|
      format.html
      format.yaml { render :text => convert_to_yaml( @package ), :content_type => Mime::TEXT }
      format.json { render :json => @package }
      format.xml { render :xml => @package }
      #format.bin { render_archive }
    end
  end

  def create
    if Package::FORMATS.values.include?( params[:package_format].upcase )
      package_format = params[:package_format].upcase
    elsif params[:package_format].nil?
      package_format = Package::FORMATS[:zip]
    else
      render_error( Error.new("Specified package format '#{params[:package_format]}' is not valid. Valid formats: #{Package::FORMATS.values.join(", ")}") )
      return
    end

    @package = Package.last(
            :conditions => {
                    :image_id => @image.id,
                    :package_format => package_format
            }
    )

    if @package.nil?

      begin
        image = Image.find( @image.id )
        definition = Definition.find( image.definition_id )
        appliance_config = read_appliance_config( definition.file )
      rescue => e
        render_error( Error.new("Appliance definition file: #{definition.file} is not valid."), e )
        return
      end

      case image.image_format
        when Image::FORMATS[:raw]
          package_file = appliance_config.path.file.package.raw
        when Image::FORMATS[:vmware]
          package_file = appliance_config.path.file.package.vmware
        else
          render_error( Error.new("No known image format: #{image.image_format} selected to package.") )
          return
      end

      @package = Package.new(
              :image_id => @image.id,
              :package_format => package_format,
              :file => package_file,
              :description => "Package for image id = #{@image.id} in  #{@image.image_format} format. Selected package format: #{package_format}"
      )

      return unless object_saved?( @package )

      TorqueBox::Queues.enqueue( 'BoxGrinder::ActionQueue', :execute,
                                 Base64.encode64(
                                         {:task => Task.new(
                                                 :artifact => ARTIFACTS[:package],
                                                 :artifact_id => @package.id,
                                                 :action => Package::ACTIONS[:build],
                                                 :description => "Building package with id = #{@package.id}." )
                                         }.to_yaml)
      )

    end

    render_general( @package, 'packages/show' )
  end

  def download
    unless is_package_status?( :built )
      error = Error.new("Selected package (id = #{@package.id}) is in #{@package.status} state. You cannot download this package.")

      render_error( error )
      return
    end

    case @package.package_format
      when Package::FORMATS[:zip]
        type = 'application/zip'
      when Package::FORMATS[:targz]
        type = 'application/x-gtar'
      else
        head :not_found
        return
    end

    send_file "#{Rails.root}/#{@package.file}", :type => type
  end

  def destroy
    logger.info "Removing package with id = #{@package.id}..."

    @package.status = Package::STATUSES[:removing]

    return unless object_saved?( @package )

    TorqueBox::Queues.enqueue( 'BoxGrinder::ActionQueue', :execute,
                               Base64.encode64(
                                       { :task => Task.new(
                                               :artifact => ARTIFACTS[:package],
                                               :artifact_id => @package.id,
                                               :action => Package::ACTIONS[:remove],
                                               :description => "Removing package with id = #{@package.id}.")
                                       }.to_yaml)
    )

    redirect_to packages_path
  end
end
