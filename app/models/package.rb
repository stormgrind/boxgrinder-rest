class Package < ActiveRecord::Base
  FORMATS = { :zip => 'ZIP', :tgz => 'TGZ' }
  ACTIONS = { :build => 'BUILD', :remove => 'REMOVE' }
  STATUSES = { :new => 'NEW', :building => 'BUILDING', :built => 'BUILT', :error => 'ERROR', :removing => 'REMOVING' }

  validates_presence_of :status, :description, :package_format
  belongs_to :image

  def initialize(attributes = nil)
    super
    self.status = STATUSES[:new]
    self.created_at = self.updated_at = Time.now
  end
end
