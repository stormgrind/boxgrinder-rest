require 'rbconfig'
require 'definitions_helper'

module PackagesHelper
  include BaseHelper
  include DefinitionsHelper

  private

  def is_package_status?( status )
    return false if @package.status.nil?
    @package.status.eql?( Package::STATUSES[status] )
  end

  def is_package_in_progress?
    return true if @package.status.eql?( Package::STATUSES[:building] )
    false
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
    unless is_package_status?( :built )
      error = Error.new("Selected image (id = #{params[:id]}) is in #{@package.status} state. You cannot download this package.")

      render_error( error )
      return
    end

    case @package.package_format
      when Package::FORMATS[:zip]
        type = 'application/zip'
      when Package::FORMATS[:targz]
        type = 'application/x-gtar'
      else
        head :not_found
        return
    end

    send_file "#{Rails.root}/#{@package.file}", :type => type
  end
end
