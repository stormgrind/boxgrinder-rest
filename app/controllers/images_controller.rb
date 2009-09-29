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
    if params[:image_format].nil? or !IMAGE_FORMATS.values.include?( params[:image_format].upcase )
      image_format = IMAGE_FORMATS[:raw]
    else
      image_format = params[:image_format].upcase
    end

    # 1.check if there is an built image
    begin
      @image = Image.find( :conditions => "definition_id = '#{params[:definition_id]}' and image_format = '#{image_format}'" )
      render_general( @image )
      return
    rescue ActiveRecord::RecordNotFound => e
      # it's ok, don't worry
    end

    task_params = Base64.encode64({'definition_id' => params[:definition_id], 'image_format' => image_format }.to_yaml)

    # 2. check if there is a task for building this image
    @task = Task.last(:conditions => "artifact = '#{ARTIFACTS[:image]}' and action = '#{IMAGE_ACTIONS[:build]}' and params = '#{task_params}'")

    if @task.nil?
      @task = Task.new( :artifact => ARTIFACTS[:image], :action => IMAGE_ACTIONS[:build], :params => task_params, :description => "Creating image from definition with id = #{params[:definition_id]}." )
      @task.save!
    end

    render_task
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
      render_error( Error.new( "Only RAW images can be converted, this image is in #{@image.type} format."))
      return
    end

    # if is in desired format
    if is_image_format?( params[:image_format].downcase.to_sym )
      render_error( Error.new( "Image is in #{params[:image_format].upcase} format, no conversion needed."))
      return
    end

    begin
      @image = Image.find( :conditions => "definition_id = '#{@image.definition_id}' and image_format = '#{params[:image_format].upcase}'" )
      render_general( @image )
      return
    rescue ActiveRecord::RecordNotFound => e
      # it's ok, don't worry
    end

    task_params = Base64.encode64({'image_format' => params[:image_format] }.to_yaml)

    @task = Task.last(:conditions => "artifact = '#{ARTIFACTS[:image]}' and artifact_id = '#{@image.id}' and action = '#{IMAGE_ACTIONS[:convert]}' and param = '#{task_params}'")

    if @task.nil?
      @task = Task.new( :artifact => ARTIFACTS[:image], :artifact_id => @image.id, :action => IMAGE_ACTIONS[:convert], :params => task_params, :description => "Converting image with id = #{params[:id]} to format #{params[:image_format].upcase}." )
      @task.save!
    end

    render_task
  end

  def destroy
    return unless image_loaded?( params[:id] )

    @task = Task.last(:conditions => "artifact = '#{ARTIFACTS[:image]}' and artifact_id = '#{@image.id}' and action = '#{IMAGE_ACTIONS[:destroy]}'")

    if @task.nil?
      @task = Task.new(:artifact => ARTIFACTS[:image], :artifact_id => @image.id, :action => IMAGE_ACTIONS[:destroy], :description => "Destroing image with id = #{@image.id}.")
      @task.save!
    end

    render_task
  end

end
