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
    @definition.status.eql?( DEFINITION_STATUSES[status] )
  end

end
