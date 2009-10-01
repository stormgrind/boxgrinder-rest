class Task

  ACTIONS = { :abort => 'ABORT' }
  STATUSES = { :completed => 'COMPLETED', :running => 'RUNNING', :aborted => 'ABORTED', :waiting => 'WAITING', :failed => 'FAILED', :new => 'NEW' }

  def initialize( values = {})
    @status       = values[:status] || STATUSES[:new]
    @created_at   = Time.now
    @artifact     = values[:artifact]
    @artifact_id  = values[:artifact_id]
    @action       = values[:action]
    @description  = values[:description]
  end

  attr_accessor :status
  attr_accessor :artifact
  attr_accessor :artifact_id
  attr_accessor :action
  attr_accessor :description
  attr_accessor :created_at
end
