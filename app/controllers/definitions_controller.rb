require 'digest/md5'
require 'boxgrinder/validator/appliance-definition-validator'
require 'boxgrinder/config'
require 'boxgrinder/helpers/appliance-config-helper'

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

    # TODO this is not cool
    FileUtils.mkdir_p( File.join(Rails.root, "appliances" ), :mode => 0755 )
    tmp_definition_file = File.join(Rails.root, "appliances_tmp", @definition_yaml['name'] + '.appl')
    FileUtils.mkdir_p( File.dirname( tmp_definition_file ), :mode => 0755 )
    File.open(tmp_definition_file, "w") { |f| f.write( @definition_content ) }

    appliance_config = read_appliance_config( tmp_definition_file )

    return unless appliance_config

    @definition = Definition.new
    @definition.name = appliance_config.name
    @definition.description = appliance_config.summary
    @definition.file = File.join(Rails.root, "appliances", @definition.name + '.appl')

    while File.exists?( @definition.file )
      render_error( Error.new( "Appliance with name #{@definition.name} already exists." ) )
      return
    end

    FileUtils.mkdir_p( File.dirname( @definition.file ), :mode => 0755 )

    logger.info "Storing new definition in #{@definition.file} file..."

    FileUtils.mv( tmp_definition_file, @definition.file )

    @definition.status = Definition::STATUSES[:created]

    logger.info "Definition stored."

    @definition.save!

    render_general( @definition, 'definitions/show' )
  end

  def destroy
    logger.info "Removing definition with id = #{@definition.id}..."

    @definition.status = Definition::STATUSES[:removed]
    @definition.delete

    #Task.new( :artifact => ARTIFACTS[:definition], :artifact_id => @definition.id, :action => DEFINITION_ACTIONS[:destroy], :description => "Destroying definition with id == #{@definition.id}." ).save!

    render_general( @definition, 'definitions/show' )
  end
end
