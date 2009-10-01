class TasksController < BaseController
  include TasksHelper

  layout 'actions'

  # shows all tasks
  def index
    unless params[:status].nil?
      @tasks = Task.all(:conditions => { 'status' => params[:status].upcase } )
    else
      @tasks = Task.all
    end

    render_general( @tasks )
  end

  def show
    return unless task_loaded?( params[:id] )
    render_general( @task )
  end

  def abort
    load_task

    @task = Task.last(:conditions =>  {:artifact => ARTIFACTS[:task], :artifact_id => @task.id, :action => Task::ACTIONS[:abort]})

    if @task.nil?
      @task = Task.new(:artifact => ARTIFACTS[:task], :artifact_id => @task.id, :action => Task::ACTIONS[:abort], :description => "Abortting task with id = #{@task.id}.")
      @task.save!
    end

    render_general( @task )
  end
end
