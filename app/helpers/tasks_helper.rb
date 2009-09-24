module TasksHelper
  include BaseHelper

  def is?( status )
    return false if @task.status.nil?
    @task.status.eql?( TASK_STATUS[status] )
  end
end
