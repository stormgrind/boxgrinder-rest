class Image < ActiveRecord::Base
  ACTIONS = { :build => 'BUILD', :package => 'PACKAGE', :convert => 'CONVERT', :remove => 'REMOVE' }
  STATUSES = { :new => 'NEW', :building => 'BUILDING', :converting => 'CONVERTING', :built => 'BUILT', :converted => 'CONVERTED', :removing => 'REMOVING', :error => 'ERROR' }
  FORMATS = { :raw => 'RAW', :vmware => 'VMWARE', :ec2 => 'EC2' }

  validates_presence_of :status, :description
  belongs_to :appliance
  belongs_to :node
  has_one :package
  has_many :images, :foreign_key => "parent_id", :dependent => :destroy
  belongs_to :parent, :class_name => "Image"

  def after_initialize
    if self.status.nil?
      self.status     = STATUSES[:new]
      self.created_at = self.updated_at = Time.now
    end
  end
end
