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

    render_task( @tasks, 'tasks/index')
  end

  def show
    load_task

    render_task( @task )
  end

  def abort
    load_task

    #TODO add here some meat
    @task.status = TASK_STATUS[:aborted]
    @task.save!

    render_task( @task )
  end

  private

  def load_task
    begin
      @task = Task.find(params[:id])
      return true
    rescue ActiveRecord::RecordNotFound => e
      logger.info "Task with id == '#{params[:id]}' not found!", e
    end
    false
  end

  def render_task( o, html_template = 'tasks/show' )
    respond_to do |format|
      format.html { render html_template }
      format.yaml { render :text => convert_to_yaml( o ), :content_type => Mime::TEXT }
      format.json { render :json => o }
      format.xml { render :xml => o }
    end
  end

end
