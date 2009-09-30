class Definition < ActiveRecord::Base
  ACTION = { :create => 'CREATE', :destroy => 'DESTROY' }
  STATUS = { :new => 'NEW', :created => 'CREATED', :error => 'ERROR', :removed => 'REMOVED'}

  validates_presence_of :status, :description

  def initialize(attributes = nil)
    super
    self.status = Defaults::DEFINITION_STATUSES[:new]
    self.created_at = self.updated_at = Time.now
  end
end
