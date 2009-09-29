module BaseHelper
  include Defaults
  include ConversionHelper

  private

  def render_error( error )
    @error = error

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

  def render_general( o )
    respond_to do |format|
      format.html
      format.yaml { render :text => convert_to_yaml( o ), :content_type => Mime::TEXT }
      format.json { render :json => o }
      format.xml { render :xml => o }
    end
  end
end