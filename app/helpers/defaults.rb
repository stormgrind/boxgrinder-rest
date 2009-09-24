module Defaults
  IMAGE_STATUS = { :building => 'BUILDING', :packaging => 'PACKAGING', :built => 'BUILT', :packaged => 'PACKAGED', :new => 'NEW', :invalid => 'INVALID' }
  TASK_STATUS = { :completed => 'COMPLETED', :running => 'RUNNING', :aborted => 'ABORTED', :waiting => 'WAITING', :failed => 'FAILED', :new => 'NEW' }
  PACKAGE_FORMAT = [ :zip, :tar, :targz ]
end