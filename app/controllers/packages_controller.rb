class PackagesController < ApplicationController
  include PackagesHelper
  include ImagesHelper

  layout 'actions'

  def index
    @packages = Package.all
    render_general( @packages )
  end

  def show
    return unless package_loaded?( params[:id] )

    respond_to do |format|
      format.html
      format.yaml { render :text => convert_to_yaml( @package ), :content_type => Mime::TEXT }
      format.json { render :json => @package }
      format.xml { render :xml => @package }
      format.zip { render_archive }
      format.tar { render_archive }
      format.tgz { render_archive }
    end
  end

  def create
    return unless image_loaded?(params[:image_id]) and image_valid?

    if params[:package_format].nil? or !Package::FORMATS.values.include?( params[:package_format].upcase )
      package_format = Package::FORMATS[:zip]
    else
      package_format = params[:package_format].upcase
    end

    @package = Package.last( :conditions => { :image_id => @image.id, :package_format => package_format } )

    if @package.nil?
      @package = Package.new( :image_id => @image.id, :package_format => package_format, :description => "Package for image id = #{@image.id} in  #{@image.image_format} format. Selected package format: #{package_format}" )
      @package.save!

      Task.new( :artifact => ARTIFACTS[:package], :artifact_id => @package.id, :action => Package::ACTIONS[:build], :description => "Building package with id = #{@package.id}." ).save!
    end

    render_general( @package, 'packages/show' )
  end
end
