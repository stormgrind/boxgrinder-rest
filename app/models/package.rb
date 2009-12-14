class Package < ActiveRecord::Base
  FORMATS = { :zip => 'ZIP', :tar => 'TAR', :targz => 'TARGZ' }
  ACTIONS = { :build => 'BUILD', :destroy => 'DESTROY' }
  STATUSES = { :new => 'NEW', :creating => 'CREATING', :created => 'CREATED', :error => 'ERROR' }

  belongs_to :image

  self.skip_time_zone_conversion_for_attributes=[]

  def initialize(attributes = nil)
    super
    self.status = STATUSES[:new]
    self.created_at = self.updated_at = Time.now
  end
end
