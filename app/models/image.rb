class Image < ActiveRecord::Base

  validates_presence_of :status, :description
  validates_numericality_of :artifact_id, :only_integer => true

  belongs_to :definition

end
