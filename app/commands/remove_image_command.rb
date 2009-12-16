require 'commands/base_command'

class RemoveImageCommand
  include BaseCommand
  include DefinitionsHelper

  def initialize( image )
    @image      = image
    @definition = Definition.find( @image.definition_id )
  end

  def execute
    logger.info "Removing image with id = #{@image.id} and #{@image.image_format} format..."

    appliance_config = read_appliance_config( @definition.file )

    puts appliance_config.path.dir.raw.build
    puts appliance_config.path.dir.ec2.build
    puts appliance_config.path.dir.vmware.build


    return
    
    name = YAML.load_file( @definition.file )['name']
    command = nil

    puts name

    case @image.image_format
      when 'VMWARE' then
        command = "build/appliances appliance:#{name}:vmware:personal appliance:#{name}:vmware:enterprise"
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