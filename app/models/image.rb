class Image < ActiveRecord::Base

  STATUS = { :new => 'NEW', :building => 'BUILDING', :built => 'BUILT', :error => 'ERROR', :removed => 'REMOVED' }
  FORMAT = { :raw => 'RAW', :vmware => 'VMWARE', :ec2 => 'EC2' }

  validates_presence_of :status, :description

  belongs_to :definition

  def initialize(attributes = nil)
    super
    self.status = Defaults::IMAGE_STATUSES[:new]
    self.created_at = self.updated_at = Time.now
  end

end
