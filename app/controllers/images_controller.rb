require "base64"

class ImagesController < BaseController
  include ImagesHelper

  layout 'actions' #, :only => :index

  def index
    @images = Image.all
    render_general( @images )
  end

  # shows selected image in different formats
  def show
    return unless image_loaded?( params[:id] )
    render_general( @image )
  end

  def create
    if params[:definition_id].nil? or !params[:definition_id].match(/\d+/)
      render_error( Error.new( "No or not valid definition_id parameter specified." ) )
      return
    end

    # image_format is optional, if no image_format paraeter is secified RAW format will be used
    if params[:image_format].nil?
      image_format = IMAGE_FORMATS[:raw]
    else
      unless IMAGE_FORMATS.values.include?( params[:image_format].upcase )
        render_error( Error.new( "Invalid format speficied. Available formats: #{IMAGE_FORMATS.values.join(", ")}"))
        return
      end
      image_format = params[:image_format].upcase
    end

    # 1.check if there is an built image
    @image = Image.last( :conditions => { :definition_id => params[:definition_id], :image_format => image_format} )

    if @image.nil?
      @image = Image.new( :definition_id => params[:definition_id], :image_format => image_format, :description => "Image for definition id = #{params[:definition_id]} and #{image_format} format." )
      @image.save!
      Task.new( :artifact => ARTIFACTS[:image], :artifact_id => @image.id, :action => IMAGE_ACTIONS[:build], :description => "Creating image from definition with id = #{params[:definition_id]}." ).save!
    end

    render_general( @image, 'images/show' )
  end

  # convert image to specified type
  def convert
    return unless image_loaded?( params[:id] ) and image_valid?

    # if there is no format specified
    if (params[:image_format].nil? or !IMAGE_FORMATS.values.include?( params[:image_format].upcase ))
      render_error( Error.new( "Invalid or no image_format parameter specified for converting image id = #{@image.id}}"))
      return
    end

    # if image format is not RAW
    unless is_image_format?( :raw )
      render_error( Error.new( "Only RAW images can be converted, this image is in #{@image.image_format} format."))
      return
    end

    # if is in desired format
    if is_image_format?( params[:image_format].downcase.to_sym )
      render_error( Error.new( "Image is in #{params[:image_format].upcase} format, no conversion needed."))
      return
    end

    @image = Image.last( :conditions => { :definition_id => @image.definition_id, :image_format => params[:image_format].upcase} )

    if @image.nil?
      @image = Image.new( :definition_id => @image.definition_id, :image_format => params[:image_format].upcase, :description => "Image for definition id = #{@image.definition_id} and #{params[:image_format].upcase} format." )
      @image.save!
    end

    Task.new(:artifact => ARTIFACTS[:image], :artifact_id => @image.id, :action => IMAGE_ACTIONS[:convert], :description => "Converting image with id = #{params[:id]} to format #{params[:image_format].upcase}.").save!

    render_general( @image, 'images/show' )
  end

  def destroy
    return unless image_loaded?( params[:id] )

    @image.status = IMAGE_STATUSES[:removed]
    @image.delete

    render_general( @image, 'images/show' )
  end
end
