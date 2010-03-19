require 'boxgrinder-core/models/task'

class PackagesController < BaseController
  include PackagesHelper

  layout 'actions'

  before_filter :load_package, :except => [ :create, :index ]

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
    param_image_id      = params[:image_id]       || nil

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
                    :image_id       => param_image_id,
                    :package_format => package_format
            }
    )

    if @package.nil?
      begin
        image             = Image.find( param_image_id )
        appliance         = Appliance.find( image.appliance_id )
        appliance_config  = YAML.load( appliance.config )
      rescue => e
        render_error( Error.new("Something went wrong, check logs for more info.", e) )
        return
      end

      if image.status != Image::STATUSES[:built]
        render_error( Error.new( "Image '#{image.id}' is in invalid status (#{image.status}). Package can be built only for images in status #{Image::STATUSES[:built]}."))
        return
      end

      @package = Package.new(
              :image_id       => image.id,
              :package_format => package_format,
              :description    => "Package for image id = #{image.id} in #{image.image_format} format. Selected package format: #{package_format}"
      )

      return unless object_saved?( @package )

      enqueue_task( "/queues/boxgrinder/#{appliance_config.os.name}/#{appliance_config.os.version}/#{image.arch}/package",
                    BoxGrinder::Task.new( :build, "Creating #{package_format} package from #{appliance_config.name} image (id = #{image.id}), #{image.image_format} format and #{image.arch}} architecture.", {
                            :appliance_config   => appliance_config,
                            :package_format     => package_format,
                            :image_format       => image.image_format,
                            :package_id         => @package.id
                    })
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
      when Package::FORMATS[:tgz]
        type = 'application/x-compressed'
      else
        head :not_found
        return
    end

    send_file "#{Rails.root}/#{@package.file}", :type => type
  end

  def destroy
    unless [ Package::STATUSES[:new], Package::STATUSES[:built], Package::STATUSES[:error] ].include?(@package.status)
      render_error( Error.new( "Current package status (#{@package.status}) doesn't allow to remove it. Try again later."))
      return
    end

    logger.info "Removing package with id = #{@package.id}..."

    begin
      @package.destroy
    rescue => e
      render_error( Error.new( "An error occurred while destroying package. See logs for more info.", e))
      return
    end

    logger.info "Package with id = #{@package.id} removed."

    redirect_to packages_path
  end
end
