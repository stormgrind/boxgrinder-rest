module DefinitionsHelper
  include BaseHelper

  private

  def definition_loaded?
    begin
      @definition = Definition.find(params[:id])
      return true
    rescue ActiveRecord::RecordNotFound => e
      render_error(Error.new( "Definition with id = #{params[:id]} not found.", e ))
    rescue => e
      render_error( Error.new( "Unexpected error while retrieving definition with id = #{params[:id]}.", e ))
    end
    false
  end

  def is_definition_status?( status )
    return false if @definition.status.nil?
    @definition.status.eql?( DEFINITION_STATUSES[status] )
  end
  
end
