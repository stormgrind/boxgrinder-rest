require 'boxgrinder/validator/appliance-definition-validator'
require 'boxgrinder/config'
require 'boxgrinder/helpers/appliance-config-helper'

module DefinitionsHelper
  include BaseHelper

  private

  def definition_hash
    Digest::MD5.hexdigest(@definition.created_at.to_s + @definition_file.to_s)
  end

  def load_definition
    id = params[:id]

    if id.nil? or !id.match(/\d+/)
      render_error(Error.new( "Invalid definition id provided: #{id}" ))
      return false
    end

    begin
      @definition = Definition.find( id )
      return true
    rescue ActiveRecord::RecordNotFound => e
      render_error(Error.new( "Definition with id = #{id} not found.", e ))
    rescue => e
      render_error( Error.new( "Unexpected error while retrieving definition with id = #{id}.", e ))
    end
    false
  end

  def is_definition_status?( status )
    return false if @definition.status.nil?
    @definition.status.eql?( Definition::STATUSES[status] )
  end

  def read_appliance_config( appliance_definition_file )

    appliance_definition_yaml = YAML.load_file( appliance_definition_file )
    appliance_definitions = {}

    # TODO why I cannot specify an array of arguments for Dir[]?!
    Dir[ "#{File.dirname( __FILE__ )}/../../lib/boxgrinder-build/appliances/*.appl" ].each { |def_file| read_appliance_definition(def_file, appliance_definitions) }
    Dir[ File.join(Rails.root, 'appliances', '*.appl') ].each { |def_file| read_appliance_definition(def_file, appliance_definitions) }

    appliance_definitions[appliance_definition_yaml['name']] = { :definition => appliance_definition_yaml, :file => appliance_definition_file }

    appliance_config = BoxGrinder::ApplianceConfigHelper.new( appliance_definitions ).merge( BoxGrinder::ApplianceConfig.new( { :definition => appliance_definition_yaml, :file => appliance_definition_file } ) )
    BoxGrinder::ApplianceDefinitionValidator.new( appliance_definition_yaml, appliance_definition_file ).validate

    appliance_config
  end

  def read_appliance_definition(appliance_definition_file, appliance_definitions)
    appliance_definition = YAML.load_file( appliance_definition_file )
    appliance_definitions[appliance_definition['name']] = { :definition => appliance_definition, :file => appliance_definition_file }
  end

  def validate_definition_file
    msg = nil
    exception = nil
    definition_file = params[:definition]

    if definition_file.nil?
      render_error( Error.new( "No definition parameter specified in your request." ) )
      return
    end

    definition_content = params[:definition].read

    unless definition_file.content_type.eql?("application/octet-stream")
      render_error( Error.new( "Invalid content type, application/octet-stream expected." ) )
      return
    end

    begin
      definition_yaml = YAML.load( definition_content )
    rescue => e
      render_error( Error.new( "Not a valid YAML file", e) )
      return
    end

    if definition_yaml.nil?
      render_error( Error.new( "Not a valid YAML file", e) )
      return
    end

    @definition_content = definition_content
    @definition_yaml = definition_yaml
  end
end
