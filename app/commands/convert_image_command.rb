require 'commands/base_command'

class ConvertImageCommand
  include BaseCommand

  def initialize( image )
    @image      = image
  end

  def execute
    logger.info "Converting image with id = #{@image.id} and #{@image.image_format} format..."

  end
end
