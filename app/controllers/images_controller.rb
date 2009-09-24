class ImagesController < BaseController

  include ImagesHelper

  layout 'actions' #, :only => :index

  # shows information in HTML format
  def index
    # TODO this is not great
    @images = Image.all

    respond_to do |format|
      format.html
      format.yaml { render :text =>  convert_to_yaml( @images ), :content_type => Mime::TEXT }
      format.json { render :json => @images }
      format.xml { render :xml => @images }
    end
  end

  # shows selected image
  def show
    return unless load_image

    respond_to do |format|
      format.html
      format.yaml { render :text => convert_to_yaml( @image ), :content_type => Mime::TEXT }
      format.json { render :json => @image }
      format.xml { render :xml => @image }
    end
  end

  # packages selected image
  def package
    return unless load_image

    archive_type = (params[:type].nil? or PACKAGE_FORMAT.include?( params[:type] )) ? :zip : params[:type]

    puts archive_type

    unless is_built?
      @task = Task.last(:conditions => "image_id = '#{@image.id}'")
    else
      @task = Task.new
      @task.description = "Packaging image with id == #{@image.id}."
      @task.image_id = @image.id
      @task.created_at = @task.updated_at = Time.now
      @task.status = "NEW"
      @task.save!
    end

    respond_to do |format|
      format.html { render :action => 'task' }
      format.yaml { render :text => convert_to_yaml( @task ), :content_type => Mime::TEXT }
      format.json { render :json => @task }
      format.xml { render :xml => @task }
    end
  end

  # build an image
  def task
    return unless load_image

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
      format.html  { render :action => 'task' }
      format.yaml { render :text => convert_to_yaml( @task ), :content_type => Mime::TEXT }
      format.json { render :json => @task }
      format.xml { render :xml => @task }
    end
  end

# prepares an image to download
  def download
    return unless load_image

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

  def load_image
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
      return false
    end
  end

end
