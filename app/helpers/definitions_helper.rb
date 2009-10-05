module DefinitionsHelper
  include BaseHelper

  private

  def definition_loaded?( id )
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

  def validate_definition_file
    msg                 = nil
    exception           = nil
    definition_file     = params[:definition]

    if definition_file.nil?
      render_error( Error.new( "No definition parameter specified in your request." ) )
      return
    end

    definition_content  = params[:definition].read

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

    if definition_yaml['description'].nil?
      render_error( Error.new( "Definition file doesn't contain description attribute.") )
      return
    end

    @definition_content  = definition_content
    @definition_yaml     = definition_yaml
  end
end
