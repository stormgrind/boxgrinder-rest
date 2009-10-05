class Image < ActiveRecord::Base

  ACTIONS = { :build => 'BUILD', :package => 'PACKAGE', :convert => 'CONVERT', :remove => 'REMOVE' }
  STATUSES = { :new => 'NEW', :building => 'BUILDING', :created => 'CREATED', :error => 'ERROR', :removed => 'REMOVED', :removing => 'REMOVING' }
  FORMATS = { :raw => 'RAW', :vmware => 'VMWARE', :ec2 => 'EC2' }

  validates_presence_of :status, :description

  belongs_to :definition

  def initialize(attributes = nil)
    super
    self.status = STATUSES[:new]
    self.created_at = self.updated_at = Time.now
  end

end
