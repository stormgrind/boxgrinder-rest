module PackagesHelper
  include BaseHelper

  private

  def is_package_status?( status )
    return false if @package.status.nil?
    @package.status.eql?( Package::STATUSES[status] )
  end

  def load_package
    id = params[:id]

    if id.nil? or !id.match(/\d+/)
      render_error(Error.new( "Invalid package id provided: #{id}" ))
      return false
    end

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

  def render_archive
    unless is_package_status?( :created )
      if is_package_status?( :error )
        error = Error.new("Selected image (id = #{params[:id]}) is in #{@package.status} state. You cannot download this package.")
      else
        error = Error.new("Selected image (id = #{params[:id]}) is in #{@package.status} state instead of #{Package::STATUSES[:created]}.")
      end

      render_error( error )
      return
    end

    head :not_found

    #send_file 'aaa', :type => 'application/zip'
    #head :multiple_choices, :location => [ "#{image_path}.tar" ]  
  end
end
