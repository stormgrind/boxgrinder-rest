require 'commands/base_command'

class BuildImageCommand
  include BaseCommand

  def initialize( image )
    @image      = image
    @definition = Definition.find( @image.definition_id )
  end

  def execute
    logger.info "Building image with id = #{@image.id} and #{@image.image_format} format..."

    name = YAML.load_file( @definition.file )['name']
    command = nil

    case @image.image_format
      when 'VMWARE' then
        command = "appliance:#{name}:vmware:personal appliance:#{name}:vmware:enterprise"
      when 'EC2' then
        command = "appliance:#{name}:ec2"
      when 'RAW' then
        command = "appliance:#{name}"
    end

    @image.status = Image::STATUSES[:building]
    save_object( @image )

    `cd #{Rails.root} && /bin/bash -c 'rake -f appliance-support.rake #{command}'`

    if $?.to_i != 0
      @image.status = Image::STATUSES[:error]
      logger.error "An error occured while building image with id = #{@image.id}. Check logs for more info."
    else
      @image.status = Image::STATUSES[:built]
      logger.info "Image with id = #{@image.id} was built successfully."
    end

    save_object( @image )
  end
end