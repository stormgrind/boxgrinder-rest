class TasksController < ApplicationController

  include ConversionHelper

  layout 'actions', :only => :index
  helper_method :convert_tasks_to_yaml  

  # shows information in HTML format
  def index
    # TODO this is not great
    @tasks = Task.all

    respond_to do |format|
      format.html
      format.yaml { render :text =>  convert_to_yaml( @tasks ), :content_type => Mime::TEXT }
      format.json { render :json => @tasks }
      format.xml { render :xml => @tasks }
    end
  end

  def show
    begin
      @task = Task.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      logger.info "Task with id == '#{params[:id]}' not found!", e
    end

    respond_to do |format|
      format.html
      format.yaml { render :text => convert_to_yaml( @task ), :content_type => Mime::TEXT }
      format.json { render :json => @task }
      format.xml { render :xml => @task }
    end
  end
end
