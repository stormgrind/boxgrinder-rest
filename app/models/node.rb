class Node < ActiveRecord::Base
  validates_presence_of :name, :address, :os_name, :os_version, :arch
end
