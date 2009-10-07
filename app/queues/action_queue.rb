require 'torquebox/queues/base'
require 'base64'
require 'yaml'
require 'commands/build_image_command'

class ActionQueue
  include TorqueBox::Queues::Base

  def execute(payload={})
    begin
      @task = YAML.load(Base64.decode64(payload[:task]))
    rescue => e
      log.error( "An error occured while decoding received task: #{payload[:task]}", e )
    end

    log.info( "Executing task for artifact = #{@task.artifact}, artifact_id = #{@task.artifact_id} and action = #{@task.action}" )

    case @task.artifact
      when Defaults::ARTIFACTS[:image] then
        execute_on_image
    end

    log.info "Task executed."
  end

  private

  def execute_on_image
    begin
      image = Image.find( @task.artifact_id )
    rescue ActiveRecord::RecordNotFound => e
      log.fatal "Image with id = #{@task.artifact_id} not found while executing task."
      return
    end

    case @task.action
      when Image::ACTIONS[:build] then
        BuildImageCommand.new( image ).execute
      when Image::ACTIONS[:convert] then
        BuildImageCommand.new( image ).execute
    end
  end

end
