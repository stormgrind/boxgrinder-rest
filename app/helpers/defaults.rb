module Defaults
  ARTIFACTS = { :definition => 'DEFINITION', :image => 'IMAGE', :package => 'PACKAGE', :task => 'TASK' }
  #
  DEFINITION_ACTIONS = { :create => 'CREATE', :destroy => 'DESTROY' }
  DEFINITION_STATUSES = { :created => 'CREATED', :error => 'ERROR' }
  #
  IMAGE_ACTIONS = { :build => 'BUILD', :package => 'PACKAGE', :convert => 'CONVERT', :destroy => 'DESTROY' }
  IMAGE_STATUSES = { :building => 'BUILDING', :built => 'BUILT', :error => 'ERROR' }
  #
  PACKAGE_ACTIONS = { :build => 'BUILD', :destroy => 'DESTROY' }
  PACKAGE_STATUSES = { :creating => 'CREATING', :created => 'CREATED', :error => 'ERROR' }

  TASK_ACTIONS = { :abort => 'ABORT' }
  TASK_STATUSES = { :completed => 'COMPLETED', :running => 'RUNNING', :aborted => 'ABORTED', :waiting => 'WAITING', :failed => 'FAILED', :new => 'NEW' }

  #
  PACKAGE_FORMAT = [ :zip, :tar, :targz ]

  IMAGE_FORMATS = { :raw => 'RAW', :vmware => 'VMWARE', :ec2 => 'EC2' }
end