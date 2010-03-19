class Image < ActiveRecord::Base
  ACTIONS = { :build => 'BUILD', :package => 'PACKAGE', :convert => 'CONVERT', :remove => 'REMOVE' }
  STATUSES = { :new => 'NEW', :building => 'BUILDING', :built => 'BUILT', :removing => 'REMOVING', :error => 'ERROR' }
  FORMATS = { :raw => 'RAW', :vmware => 'VMWARE', :ec2 => 'EC2' }

  validates_presence_of :status, :description
  belongs_to :appliance
  has_one :package

  def after_initialize
    if self.status.nil?
      self.status     = STATUSES[:new]
      self.created_at = self.updated_at = Time.now
    end
  end
end
