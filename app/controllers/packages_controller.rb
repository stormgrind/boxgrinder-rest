class PackagesController < ApplicationController
  include PackagesHelper
  include ImagesHelper

  layout 'actions'

  def index
    @packages = Package.all
    render_general( @packages )
  end

  def show
    return unless package_loaded?( params[:id] )
    render_general( @package )
  end

  def create
    return unless image_loaded?(params[:image_id]) and image_valid?

    @task = Task.last(:conditions => "image_id = '#{@image.id}'")

    if is_image_status?( :built ) and @task.nil? or @task.action.eql?( IMAGE_ACTIONS[:build] )
      archive_type = (params[:archive_type].nil? or PACKAGE_FORMAT.include?( params[:archive_type] )) ? :zip : params[:archive_type]

      @task = Task.new( :artifact => :package, :action => PACKAGE_ACTIONS[:build], :description => "Creating package of image with id = #{@image.id}.", :params => [ archive_type ] )
      @task.save!
    end

    render_task
  end

  # prepares an image to download
  def download
    return unless package_loaded?( params[:id] )

    unless is_image_status?( :packaged )
      respond_to do |format|
        format.html { render :text => "Package first!" }
      end
      return
    end

    respond_to do |format|
      format.html { render :text=> 'Downloading...' }
      format.yaml { render :text => convert_to_yaml( @image ), :content_type => Mime::TEXT }
      format.json { render :json => @image }
      format.xml { render :xml => @image }
      format.zip { render_archive }
      format.tar { render_archive }
      format.tgz { render_archive }
    end
  end

end
