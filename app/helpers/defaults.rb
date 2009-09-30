module Defaults
  ARTIFACTS = { :definition => 'DEFINITION', :image => 'IMAGE', :package => 'PACKAGE', :task => 'TASK' }
  #
  DEFINITION_ACTIONS = { :create => 'CREATE', :destroy => 'DESTROY' }
  DEFINITION_STATUSES = { :new => 'NEW', :created => 'CREATED', :error => 'ERROR', :removed => 'REMOVED'}
  #
  IMAGE_ACTIONS = { :build => 'BUILD', :package => 'PACKAGE', :convert => 'CONVERT', :destroy => 'DESTROY' }
  IMAGE_STATUSES = { :new => 'NEW', :building => 'BUILDING', :built => 'BUILT', :error => 'ERROR', :removed => 'REMOVED' }
  #
  PACKAGE_ACTIONS = { :build => 'BUILD', :destroy => 'DESTROY' }
  PACKAGE_STATUSES = { :new => 'NEW', :creating => 'CREATING', :created => 'CREATED', :error => 'ERROR' }

  TASK_ACTIONS = { :abort => 'ABORT' }
  TASK_STATUSES = { :completed => 'COMPLETED', :running => 'RUNNING', :aborted => 'ABORTED', :waiting => 'WAITING', :failed => 'FAILED', :new => 'NEW' }

  #
  PACKAGE_FORMATS = { :zip => 'ZIP', :tar => 'TAR', :targz => 'TARGZ' }

  IMAGE_FORMATS = { :raw => 'RAW', :vmware => 'VMWARE', :ec2 => 'EC2' }
end