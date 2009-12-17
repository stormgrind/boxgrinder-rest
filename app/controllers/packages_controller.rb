class PackagesController < ApplicationController
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
      format.zip { render_archive }
      format.tar { render_archive }
      format.tgz { render_archive }
    end
  end

  def create
    if params[:package_format].nil? or !Package::FORMATS.values.include?( params[:package_format].upcase )
      package_format = Package::FORMATS[:zip]
    else
      package_format = params[:package_format].upcase
    end

    @package = Package.last(
            :conditions => {
                    :image_id => @image.id,
                    :package_format => package_format
            }
    )

    if @package.nil?
      @package = Package.new(
              :image_id => @image.id,
              :package_format => package_format,
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

  def destroy

  end
end
