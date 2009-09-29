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
    @task = Task.new( :artifact => ARTIFACTS[:definition], :action => DEFINITION_ACTIONS[:create], :description => "Creating new definition." )

    # TODO add param with information about definition file
    @task.params = 'TODO'
    @task.save!

    render_task
  end

  def destroy
    return unless definition_loaded?

    @task = Task.new( :artifact => ARTIFACTS[:definition], :action => DEFINITION_ACTIONS[:destroy], :artifact_id => @definition.id, :description => "Destroying definition with id == #{@definition.id}." )
    @task.save!

    render_task
  end
end
