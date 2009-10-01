module TasksHelper
  include BaseHelper

  def is_task_status?( status )
    return false if @task.status.nil?
    @task.status.eql?( Task::STATUSES[status] )
  end

  def task_loaded?( id )
    return false if id.nil? or !id.match(/\d+/)
    begin
      @task = Task.find( id )
      return true
    rescue ActiveRecord::RecordNotFound => e
      render_error(Error.new( "Task with id = #{id} not found.", e ))
    rescue => e
      render_error( Error.new( "Unexpected error while retrieving task with id = #{id}.", e ))
    end
    false
  end

end
