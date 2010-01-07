require 'commands/base_command'

class BuildImageCommand
  include BaseCommand

  def initialize( image )
    @image = image
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

    begin
      execute_command("cd #{Rails.root} && PATH='/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin' /bin/bash -c 'rake -f boxgrinder.rake #{command}'")
      @image.status = Image::STATUSES[:built]
      logger.info "Image with id = #{@image.id} was built successfully."
    rescue
      @image.status = Image::STATUSES[:error]
      logger.error "An error occured while building image with id = #{@image.id}. Check logs for more info."
    end

    save_object( @image )
  end
end
