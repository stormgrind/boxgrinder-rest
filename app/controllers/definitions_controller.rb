require 'digest/md5'
#require 'boxgrinder/validators/appliance-definition-validator'
#require 'boxgrinder/helpers/appliance-config-helper'
require 'torquebox/queues'

class DefinitionsController < ApplicationController
  include DefinitionsHelper

  layout 'actions'
  before_filter :load_definition, :except => [ :create, :index ]
  before_filter :validate_definition_file, :only => [ :create ]

  def index
    @definitions = Definition.all
    render_general( @definitions )
  end

  def show
    render_general( @definition )
  end

  # TODO rewrite this!
  def create
    logger.info "Creating new definition..."

    ## TODO this is not cool
    #FileUtils.mkdir_p( File.join(Rails.root, "appliances" ), :mode => 0755 )
    #tmp_definition_file = File.join(Rails.root, "appliances_tmp", @definition_yaml['name'] + '.appl')
    #FileUtils.mkdir_p( File.dirname( tmp_definition_file ), :mode => 0755 )
    #File.open(tmp_definition_file, "w") { |f| f.write( @definition_content ) }

    #begin
    #  appliance_config = read_appliance_config( tmp_definition_file )
    #rescue => e
    # render_error( Error.new( "Appliance file is NOT valid.", e ))
    # return
    #end



    @definition             = Definition.new
    @definition.content     = @definition_yaml
    #= File.join(Rails.root, "appliances", @definition.name + '.appl')

    @appliance = Appliance.new
    @appliance.definition = @definition
    @appliance.name        = "appliance_config.name"
    @appliance.summary      = "appliance_config.summary"

    @appliance.save!

    #while File.exists?( @definition.file )
    #  render_error( Error.new( "Appliance with name #{@definition.name} already exists." ) )
    #  return
    #end

    #FileUtils.mkdir_p( File.dirname( @definition.file ), :mode => 0755 )

    #logger.info "Storing new definition in #{@definition.file} file..."

    #FileUtils.mv( tmp_definition_file, @definition.file )

    #@definition.status = Definition::STATUSES[:created]

    #logger.info "Definition stored."

    #@definition.save!

    render_general( @definition, 'definitions/show' )
  end

  def destroy
    logger.info "Removing definition with id = #{@definition.id}..."

    @definition.status = Definition::STATUSES[:removing]

    return unless object_saved?( @definition )

    TorqueBox::Queues.enqueue( 'BoxGrinder::ActionQueue', :execute,
                               Base64.encode64(
                                       { :task => Task.new(
                                               :artifact => ARTIFACTS[:definition],
                                               :artifact_id => @definition.id,
                                               :action => Definition::ACTIONS[:remove],
                                               :description => "Removing definition with id = #{@definition.id}.")
                                       }.to_yaml)
    )

    redirect_to definitions_path
  end
end
