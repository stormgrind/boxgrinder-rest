class Package < ActiveRecord::Base
  belongs_to :image

  def initialize(attributes = nil)
    super
    self.status = Defaults::PACKAGE_STATUSES[:new]
    self.created_at = self.updated_at = Time.now
  end
end
