require 'boxgrinder-core/helpers/appliance-config-helper'
require 'boxgrinder-core/models/appliance-config'

class AppliancesController < BaseController
  include AppliancesHelper

  layout 'actions'
  before_filter :load_object, :except => [ :create, :index ]
  before_filter :validate_appliance_definition_file, :only => [ :create ]

  def index
    @appliances = Appliance.all
    render_general( @appliances )
  end

  def show
    render_general( @appliance )
  end

  def create
    logger.info "Creating new Appliance..."

    appliance_config = BoxGrinder::ApplianceConfigHelper.new( Appliance.definitions ).merge( BoxGrinder::ApplianceConfig.new( @appliance_definition ) )

    if Appliance.count( :conditions => "name = '#{appliance_config.name}'" ) > 0
      render_error( Error.new( "Appliance with name '#{appliance_config.name}' already exists in repository." ) )
      return
    end

    @appliance            = Appliance.new
    @appliance.name       = appliance_config.name
    @appliance.summary    = appliance_config.summary
    @appliance.config     = appliance_config.to_yaml
    @appliance.status     = Appliance::STATUSES[:created]

    return unless object_saved?( @appliance )

    Appliance.add_definition( @appliance.name, @appliance_definition )

    render_general( @appliance, 'appliances/show' )

    logger.info "Appliance '#{@appliance.name}' created."
  end

  def destroy
    logger.info "Removing Appliance '#{@appliance.name}'..."

    @appliance.status = Appliance::STATUSES[:removing]

    return unless object_saved?( @appliance )

    images_size   = @appliance.images.size
    packages_size = @appliance.packages.size

    if images_size == 0 and packages_size == 0
      @appliance.destroy
      logger.info "Appliance '#{@appliance.name}' removed."
    else
      render_error( Error.new( "There are #{images_size} images and #{packages_size} packages you need to remove first before you remove '#{@appliance.name}' appliance." ) )
      return
    end

    redirect_to appliances_path
  end

end
