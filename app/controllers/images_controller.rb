class ImagesController < BaseController

  include ImagesHelper

  layout 'actions' #, :only => :index

  # shows information in HTML format
  def index
    unless params[:status].nil?
      @images = Image.all(:conditions => { 'status' => params[:status].upcase } )
    else
      @images = Image.all
    end

    respond_to do |format|
      format.html
      format.yaml { render :text =>  convert_to_yaml( @images ), :content_type => Mime::TEXT }
      format.json { render :json => @images }
      format.xml { render :xml => @images }
    end
  end

  # shows selected image
  def show
    return unless image_loaded?

    respond_to do |format|
      format.html
      format.yaml { render :text => convert_to_yaml( @image ), :content_type => Mime::TEXT }
      format.json { render :json => @image }
      format.xml { render :xml => @image }
    end
  end

  # packages selected image
  def package
    return unless image_loaded? and image_valid?

    @task = Task.last(:conditions => "image_id = '#{@image.id}'")

    if is_built? and @task.nil? or @task.action.eql?( IMAGE_ACTIONS[:build] )
      archive_type = (params[:type].nil? or PACKAGE_FORMAT.include?( params[:type] )) ? :zip : params[:type]

      @task = Task.new
      @task.description = "Packaging image with id == #{@image.id}."
      @task.image_id = @image.id
      @task.created_at = @task.updated_at = Time.now
      @task.action = IMAGE_ACTIONS[:package]
      @task.params = [ archive_type ]
      @task.status = "NEW"
      @task.save!
    end

    respond_to do |format|
      format.html { render 'tasks/show' }
      format.yaml { render :text => convert_to_yaml( @task ), :content_type => Mime::TEXT }
      format.json { render :json => @task }
      format.xml { render :xml => @task }
    end
  end

  # build an image
  def build
    return unless image_loaded? and image_valid?

    unless is_new?
      @task = Task.last(:conditions => "image_id = '#{@image.id}'")
    else
      @task = Task.new
      @task.description = "Building image with id == #{@image.id}."
      @task.image_id = @image.id
      @task.created_at = @task.updated_at = Time.now
      @task.status = "NEW"
      @task.save!
    end

    respond_to do |format|
      format.html  { render 'tasks/show' }
      format.yaml { render :text => convert_to_yaml( @task ), :content_type => Mime::TEXT }
      format.json { render :json => @task }
      format.xml { render :xml => @task }
    end
  end

# prepares an image to download
  def download
    return unless image_loaded?

    unless is_packaged?
      respond_to do |format|
        format.html { render :text => "Package first!" }
      end
      return
    end

    respond_to do |format|
      format.html { render :text=> 'Downloading...' }
    end
  end

  private

  def image_valid?
    return true unless is_invalid?

    @error = Error.new
    @error.message = "Image is invalid"

    respond_to do |format|
      format.html { render 'root/error'}
      format.yaml { render :text => convert_to_yaml( @error ), :content_type => Mime::TEXT }
      format.json { render :json => @error }
      format.xml { render :xml => @error }
    end
    false
  end

  def image_loaded?
    begin
      @image = Image.find(params[:id])
      return true
    rescue ActiveRecord::RecordNotFound => e
      respond_to do |format|
        format.html { render :text=> 'Image not found', :status=>404 }

        #format.yaml { render :text => convert_to_yaml( @image ), :content_type => Mime::TEXT }
        #format.json { render :json => @image }
        #format.xml { render :xml => @image }
      end
    end
    false
  end
end
