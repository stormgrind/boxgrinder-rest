require 'torquebox-messaging-client'

module BaseHelper
  include Defaults
  include ConversionHelper

  private

  def render_error( error )
    @error = error

    logger.error( @error.message, @error.exception )

    respond_to do |format|
      format.html { render 'root/error' }
      format.yaml { render :text => convert_to_yaml( @error ), :content_type => Mime::TEXT }
      format.json { render :json => @error }
      format.xml { render :xml => @error }
    end
  end

  def render_task
    respond_to do |format|
      format.html { render 'tasks/show' }
      format.yaml { render :text => convert_to_yaml( @task ), :content_type => Mime::TEXT }
      format.json { render :json => @task }
      format.xml { render :xml => @task }
    end
  end

  def render_general( o, html = nil )
    respond_to do |format|
      format.html { render html unless html.nil? }
      format.yaml { render :text => convert_to_yaml( o ), :content_type => Mime::TEXT }
      format.json { render :json => o }
      format.xml { render :xml => o }
    end
  end

  def load_object
    klass = eval(self.class.to_s.scan(/^(.*)sController/).to_s)
    id    = params[:id] if id_valid?(params[:id])

    if id.nil? or !id.match(/\d+/)
      render_error(Error.new( "Invalid #{klass} id provided: #{id}" ))
      return false
    end

    begin
      instance_variable_set("@#{klass.to_s.downcase}", klass.find( id ))
      return true
    rescue ActiveRecord::RecordNotFound => e
      render_error(Error.new( "#{klass} with id = #{id} not found.", e ))
    rescue => e
      render_error( Error.new( "Unexpected error while retrieving #{klass} with id = #{id}.", e ))
    end
    false
  end

  def id_valid?( id )
    return false if id.nil? or !id.match(/\d+/)
    true
  end

  def object_saved?(o)
    if o.id.nil?
      logger.info "Creating new #{o.class}..."
    else
      logger.info "Saving #{o.class} with id = #{o.id}..."
    end

    begin
      ActiveRecord::Base.transaction do
        o.save!
      end

      logger.info "#{o.class} saved (id = #{o.id})."
      return true
    rescue => e
      render_error( Error.new("Could not create new #{o.class}.", e) )
      return false
    end
  end

  def enqueue_task( queue_name, task, properties = {} )
    logger.info "Putting new task into queue '#{queue_name}' for action '#{task.action}'."

    TorqueBox::Messaging::Client.connect { |client| client.send( queue_name, :object => task, :properties => properties ) }

    logger.info "Task put into queue."
  end
end