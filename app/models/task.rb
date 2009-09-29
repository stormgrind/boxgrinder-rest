class Task < ActiveRecord::Base

  validates_presence_of :artifact, :action, :status, :description
  validates_numericality_of :artifact_id, :only_integer => true, :allow_nil => true

  def initialize(attributes = nil)
    super
    self.status = Defaults::TASK_STATUSES[:new]
    self.created_at = self.updated_at = Time.now
  end
end
