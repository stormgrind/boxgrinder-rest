#require 'action_queue'

class DefinitionsController < ApplicationController
  include DefinitionsHelper

  layout 'actions'

  def index
    @definitions = Definition.all
    render_general( @definitions )
  end

  def show
    return unless definition_loaded?( params[:id] )
    render_general( @definition )
  end

  def create
    # TODO add more info to desription
    @definition = Definition.new( :description => "Definition.")
    @definition.save!

    # TODO store somewhere uploaded definition file

    #ActionQueue.enqueue( :execute, { :task => Task.new( :artifact => ARTIFACTS[:definition], :artifact_id => @definition.id, :action => Definition::ACTIONS[:create], :description => "Creating new definition." ) } )

    render_general( @definition, 'definitions/show' )
  end

  def destroy
    return unless definition_loaded?( params[:id] )

    @definition.status = Definition::STATUSES[:removed]
    @definition.delete

    #Task.new( :artifact => ARTIFACTS[:definition], :artifact_id => @definition.id, :action => DEFINITION_ACTIONS[:destroy], :description => "Destroying definition with id == #{@definition.id}." ).save!

    render_general( @definition, 'definitions/show' )
  end
end
