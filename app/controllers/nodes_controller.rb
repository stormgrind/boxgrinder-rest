class NodesController < BaseController
  include NodesHelper

  layout 'actions'
  before_filter :load_object, :except => [ :create, :index ]

  def index
    @nodes = Node.all
    render_general( @nodes )
  end

  def show
    render_general( @node )
  end

end
