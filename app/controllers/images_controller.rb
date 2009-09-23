class ImagesController < BaseController

  include ConversionHelper

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

  end

  # prepares an image to download
  def download

  end
end
