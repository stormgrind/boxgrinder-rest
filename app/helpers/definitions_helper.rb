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
    msg         = nil
    exception   = nil
    definition_file     = params[:definition]
    definition_content  = params[:definition].read

    msg = "Invalid content type, application/octet-stream expected. " unless definition_file.content_type.eql?("application/octet-stream")
    
    begin
      definition_yaml = YAML.load( definition_content )
    rescue => e
      msg = "Not a valid YAML file"
      exception = e
    end

    if definition_yaml.nil?
      msg = "Not a valid YAML file"
    else
      msg = "Definition file doesn't contain description attribute." if definition_yaml['description'].nil?
    end

    if msg.nil?
      @definition_content  = definition_content
      @definition_yaml     = definition_yaml
    else
      render_error( Error.new( msg, exception || nil ) )
    end
  end
end
