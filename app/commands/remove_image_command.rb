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

    begin
      appliance_config = read_appliance_config( @definition.file )
    rescue => e
      logger.error "Appliance file is NOT valid."
      logger.error e
    end

    directory = nil

    case @image.image_format
      when 'VMWARE' then
        directory = appliance_config.path.dir.vmware.build
      when 'EC2' then
        directory = appliance_config.path.dir.ec2.build
      when 'RAW' then
        directory = appliance_config.path.dir.raw.build
    end

    command = "cd #{Rails.root} && sudo /bin/bash -c 'rm -rf #{directory}'"

    logger.debug "Executing command: #{command}"

    `#{command}`

    if $?.to_i != 0
      @image.status = Image::STATUSES[:error]
      logger.error "An error occured while building image with id = #{@image.id}. Check logs for more info."
    else
      logger.info "Image with id = #{@image.id} was successfully removed."
    end

    Image.destroy( @image.id )
  end
end
