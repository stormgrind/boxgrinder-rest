require 'torquebox/queues/base'
require 'base64'
require 'yaml'

class ActionQueue
  include TorqueBox::Queues::Base

  def execute(payload={})
    task = YAML.load(Base64.decode64(payload[:task]))

    puts Base64.decode64(payload[:task])

    log.info( "Received Task for artifact = #{task.artifact}, artifact_id = #{task.artifact_id} and action = #{task.action}" )

    case task.artifact
      when Defaults::ARTIFACTS[:image] then
        execute_on_image( task.artifact_id, task.action )
    end
  end

  private

  def execute_on_image( id, action )
    image = Image.find( id )

    sleep 10

    case action
      when Image::ACTIONS[:convert] then
        puts "convert"

    end

    puts image.description
  end

end
