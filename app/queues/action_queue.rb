require 'torquebox/queues/base'
require 'base64'
require 'yaml'

class ActionQueue
  include TorqueBox::Queues::Base

  def execute(payload={})
    task = YAML.load(Base64.decode64(payload[:task]))

    log.info( "Received Task for artifact = #{task.artifact}, artifact_id = #{task.artifact_id} and action = #{task.action}" )

    case task.artifact
      when Defaults::ARTIFACTS[:image] then
        execute_on_image( task.artifact_id, task.action )
    end
  end

  private

  def execute_on_image( id, action )
    begin
      image = Image.find( id )
    rescue ActiveRecord::RecordNotFound => e
      log.fatal "Image with id = #{id} not found while executing task."
      return
    end

    log.info "Executing task for Image with id = #{id}, action = #{action}..."

    sleep 10

    case action
      when Image::ACTIONS[:convert] then
        log.info "Converting image with id = #{id} to #{image.image_format}..."

    end



  end

end
