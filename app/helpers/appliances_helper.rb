require 'boxgrinder-core/validators/appliance-definition-validator'

module AppliancesHelper
  include BaseHelper

  def validate_appliance_definition_file
    logger.debug "Validating appliance definition file..."

    definition_file = params[:definition]

    if definition_file.nil?
      render_error( Error.new( "No definition parameter specified in your request." ) )
      return
    end

    definition_yaml = params[:definition].read

    unless definition_file.content_type.eql?("application/octet-stream")
      render_error( Error.new( "Invalid content type, application/octet-stream expected." ) )
      return
    end

    begin
      definition = YAML.load( definition_yaml )
    rescue => e
      render_error( Error.new( "Not a valid YAML file", e) )
      return
    end

    if definition.nil?
      render_error( Error.new( "Not a valid YAML file", e) )
      return
    end

    BoxGrinder::ApplianceDefinitionValidator.new( definition ).validate

    @appliance_definition_yaml  = definition_yaml
    @appliance_definition       = definition

    logger.debug "Appliance definition file is valid."
  end

  def is_appliance_status?( status )
    return false if @appliance.status.nil?
    @appliance.status.eql?( Appliance::STATUSES[status] )
  end

end
