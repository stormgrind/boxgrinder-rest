module PackagesHelper
  include BaseHelper

  private

  def package_loaded?( id )
    return false if id.nil? or !id.match(/\d+/)
    begin
      @package = Package.find( id )
      return true
    rescue ActiveRecord::RecordNotFound => e
      render_error(Error.new( "Package with id = #{id} not found.", e ))
    rescue => e
      render_error( Error.new( "Unexpected error while retrieving package with id = #{id}.", e ))
    end
    false
  end
end
