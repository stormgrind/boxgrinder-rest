class Definition < ActiveRecord::Base
  ACTIONS = { :create => 'CREATE', :destroy => 'DESTROY' }
  STATUSES = { :new => 'NEW', :created => 'CREATED', :error => 'ERROR', :removed => 'REMOVED'}

  validates_presence_of :status, :description

  def initialize(attributes = nil)
    super
    self.status = STATUSES[:new]
    self.created_at = self.updated_at = Time.now
  end
end
