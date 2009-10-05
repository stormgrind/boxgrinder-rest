require 'queues/action_queue' unless RAILS_ENV=='test'
require 'base64'

class ImagesController < BaseController
  include ImagesHelper

  before_filter :load_image, :except => [ :create, :index ]
  before_filter :validate_image, :except => [ :create, :index, :destroy ]

  layout 'actions'

  def index
    @images = Image.all
    render_general( @images )
  end

  # shows selected image in different formats
  def show
    render_general( @image )
  end

  def create
    param_definition_id   = params[:definition_id] || nil
    param_image_format    = params[:image_format] || nil

    if param_definition_id.nil? or !param_definition_id.match(/\d+/)
      render_error( Error.new( "No or not valid definition_id parameter specified." ) )
      return
    end

    # image_format is optional, if no image_format paraeter is secified RAW format will be used
    if param_image_format.nil?
      image_format = Image::FORMATS[:raw]
    else
      unless Image::FORMATS.values.include?( param_image_format.upcase )
        render_error( Error.new( "Invalid format speficied. Available formats: #{Image::FORMATS.values.sort.join(", ")}."))
        return
      end
      image_format = param_image_format.upcase
    end

    # 1.check if there is already a built image
    @image = Image.last(
            :conditions => {
                    :definition_id  => param_definition_id,
                    :image_format   => image_format
            }
    )

    if @image.nil?

      @image = Image.new(
              :definition_id  => param_definition_id,
              :image_format   => image_format,
              :description    => "Image for definition id = #{param_definition_id} and #{image_format} format."
      )

      return unless image_saved?

      ActionQueue.enqueue(
              :execute, {
                      :task => Base64.encode64(Task.new(
                              :artifact       => ARTIFACTS[:image],
                              :artifact_id    => @image.id,
                              :action         => Image::ACTIONS[:build],
                              :description    => "Creating image from definition with id = #{param_definition_id}." ).to_yaml)
              }
      )

      logger.info "New taks put into queue for #{ARTIFACTS[:image]} artifact, artifact_id #{@image.id} and action #{Image::ACTIONS[:build]}."
    end

    render_general( @image, 'images/show' )
  end

  # convert image to specified type
  def convert
    param_image_format    = params[:image_format] || nil

    # if there is no format specified
    if (param_image_format.nil? or !Image::FORMATS.values.include?( param_image_format.upcase ))
      render_error( Error.new( "Invalid or no image_format parameter specified for converting image id = #{@image.id}}"))
      return
    end

    # if image format is not RAW
    unless is_image_format?( :raw )
      render_error( Error.new( "Only RAW images can be converted, this image is in #{@image.image_format} format."))
      return
    end

    # TODO this is not good
    # if is in desired format
    if is_image_format?( param_image_format.downcase.to_sym )
      render_error( Error.new( "Image is in #{param_image_format.upcase} format, no conversion needed."))
      return
    end

    image = Image.last(
            :conditions => {
                    :definition_id  => @image.definition_id,
                    :image_format   => param_image_format.upcase
            }
    )

    if image.nil?

      @image = Image.new(
              :definition_id  => @image.definition_id,
              :image_format   => param_image_format.upcase,
              :description    => "Image for definition id = #{@image.definition_id} and #{param_image_format.upcase} format."
      )

      return unless image_saved?

      ActionQueue.enqueue(
              :execute, {
                      :task => Base64.encode64(Task.new(
                              :artifact     => ARTIFACTS[:image],
                              :artifact_id  => @image.id,
                              :action       => Image::ACTIONS[:convert],
                              :description  => "Converting image with id = #{@image.id} to format #{param_image_format.upcase}.").to_yaml)
              }
      )
    else
      @image = image
    end

    render_general( @image, 'images/show' )
  end

  def destroy
    @image.status = Image::STATUSES[:removing]

    return unless image_saved?

    ActionQueue.enqueue(
            :execute, {
                    :task => Base64.encode64(Task.new(
                            :artifact     => ARTIFACTS[:image],
                            :artifact_id  => @image.id,
                            :action       => Image::ACTIONS[:remove],
                            :description  => "Removing image with id = #{@image.id}.").to_yaml)
            }
    )

    render_general( @image, 'images/show' )
  end
end
