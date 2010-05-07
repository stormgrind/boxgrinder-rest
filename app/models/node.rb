class Node < ActiveRecord::Base
  STATUSES = { :active => 'ACTIVE', :inactive => 'INACTIVE' }

  validates_presence_of :name, :address, :os_name, :os_version, :arch
end
