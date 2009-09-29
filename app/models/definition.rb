class Definition < ActiveRecord::Base
  validates_presence_of :status, :description
end
