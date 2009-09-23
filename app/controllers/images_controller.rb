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
    begin
      @image = Image.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      logger.info "Image with id == '#{params[:id]}' not found!", e
    end

    respond_to do |format|
      format.html
      format.yaml { render :text => convert_to_yaml( @image ), :content_type => Mime::TEXT }
      format.json { render :json => @image }
      format.xml { render :xml => @image }
    end
  end

  # packages selected image
  def package

  end

  # build an image
  def build
    begin
      @image = Image.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      respond_to do |format|
        format.html { render :text=> 'Image not found', :status=>404 }
        format.yaml { render :text => convert_to_yaml( @image ), :content_type => Mime::TEXT }
        format.json { render :json => @image }
        format.xml { render :xml => @image }
      end
    end

    @task = Task.new
    @task.description = "Building image with id == #{@image.id}."

    if is_built?
      # if image was built before, create a temp task with completed status
      @task.status = "COMPLETED"
    else
      @task.status = "NEW"
    end

    @task.save!

    respond_to do |format|
      format.html
      format.yaml { render :text => convert_to_yaml( @task ), :content_type => Mime::TEXT }
      format.json { render :json => @task }
      format.xml { render :xml => @task }
    end

  end

  # prepares an image to download
  def download

  end
end
