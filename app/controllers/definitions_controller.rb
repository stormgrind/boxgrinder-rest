require 'digest/md5'

class DefinitionsController < ApplicationController
  include DefinitionsHelper

  layout 'actions'
  before_filter :load_definition, :except => [ :create, :index ]
  before_filter :validate_definition_file, :only => [ :create ]

  def index
    @definitions = Definition.all
    render_general( @definitions )
  end

  def show
    render_general( @definition )
  end

  def create
    logger.info "Creating new definition..."

    @definition = Definition.new

    directory = "appliances"
    hash = definition_hash

    #while File.exists?( File.join(Rails.root, directory, hash ))
    #  hash = definition_hash
    #end

    path = File.join(Rails.root, directory, hash, hash + '.appl')
    
    FileUtils.mkdir_p( File.dirname(path), :mode => 0755 )

    @definition.description = @definition_yaml['summary']
    @definition.file = path

    logger.info "Storing new definition in #{path} file..."

    if File.open(path, "w", 0644) { |f| f.write( @definition_content ) } > 0
      @definition.status = Definition::STATUSES[:created]

      logger.info "Definition stored."
    else
      @definition.status = Definition::STATUSES[:error]
      logger.info "Definition storing failed."
    end

    @definition.save!

    render_general( @definition, 'definitions/show' )
  end

  def destroy
    logger.info "Removing definition with id = #{@definition.id}..."

    @definition.status = Definition::STATUSES[:removed]
    @definition.delete

    #Task.new( :artifact => ARTIFACTS[:definition], :artifact_id => @definition.id, :action => DEFINITION_ACTIONS[:destroy], :description => "Destroying definition with id == #{@definition.id}." ).save!

    render_general( @definition, 'definitions/show' )
  end
end
