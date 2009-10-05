require 'digest/md5'

class DefinitionsController < ApplicationController
  include DefinitionsHelper

  layout 'actions'
  before_filter :validate_definition_file, :only => [ :create ]

  def index
    @definitions = Definition.all
    render_general( @definitions )
  end

  def show
    return unless definition_loaded?( params[:id] )
    render_general( @definition )
  end

  def create
    #log.info "Creating new definition..."
    @definition = Definition.new

    directory = "public/data"
    path = File.join(Rails.root, directory, @definition.created_at.strftime("%d-%m-%Y"),  Digest::MD5.hexdigest(@definition.created_at.to_s + @definition_file.to_s))
    FileUtils.mkdir_p( File.dirname(path), :mode => 0755 )

    @definition.description = @definition_yaml['description']
    @definition.file = path

    if File.open(path, "w", 0644) { |f| f.write( @definition_content ) } > 0
      @definition.status = Definition::STATUSES[:created]
    else
      @definition.status = Definition::STATUSES[:error]
    end

    @definition.save!

    render_general( @definition, 'definitions/show' )
  end

  def destroy
    return unless definition_loaded?( params[:id] )

    @definition.status = Definition::STATUSES[:removed]
    @definition.delete

    #Task.new( :artifact => ARTIFACTS[:definition], :artifact_id => @definition.id, :action => DEFINITION_ACTIONS[:destroy], :description => "Destroying definition with id == #{@definition.id}." ).save!

    render_general( @definition, 'definitions/show' )
  end
end
