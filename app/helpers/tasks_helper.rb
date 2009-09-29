module TasksHelper
  include BaseHelper

  def is_task_status?( status )
    return false if @task.status.nil?
    @task.status.eql?( TASK_STATUSES[status] )
  end
end
