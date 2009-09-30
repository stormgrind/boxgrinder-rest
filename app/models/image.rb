class Image < ActiveRecord::Base

  validates_presence_of :status, :description

  belongs_to :definition

  def initialize(attributes = nil)
    super
    self.status = Defaults::IMAGE_STATUSES[:new]
    self.created_at = self.updated_at = Time.now
  end

end
