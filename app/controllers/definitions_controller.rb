class DefinitionsController < ApplicationController
  include DefinitionsHelper

  layout 'actions'

  def index
    @definitions = Definition.all
    render_general( @definitions )
  end

  def show
    return unless definition_loaded?
    render_general( @definition )
  end

  def create
    @task = Task.new
    @task.description = "Creating new definition."
    @task.artifact = ARTIFACTS[:definition]
    @task.action = DEFINITION_ACTIONS[:create]
    # TODO add param with information about definition file
    @task.params = 'TODO'
    @task.save!

    render_task
  end

  def destroy
    return unless definition_loaded?

    @task = Task.new
    @task.description = "Destroying definition with id == #{@definition.id}."
    @task.artifact = ARTIFACTS[:definition]
    @task.artifact_id = @definition.id 
    @task.action = DEFINITION_ACTIONS[:destroy]
    @task.status = TASK_STATUSES[:new]
    @task.save!

    render_task
  end
end
