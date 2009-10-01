class Task < ActiveRecord::Base

  ACTIONS = { :abort => 'ABORT' }
  STATUSES = { :completed => 'COMPLETED', :running => 'RUNNING', :aborted => 'ABORTED', :waiting => 'WAITING', :failed => 'FAILED', :new => 'NEW' }

  validates_presence_of :artifact, :action, :status, :description
  validates_numericality_of :artifact_id, :only_integer => true, :allow_nil => true

  def initialize(attributes = nil)
    super
    self.status = STATUSES[:new]
    self.created_at = self.updated_at = Time.now
  end
end
