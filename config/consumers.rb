require 'consumers/image-manager-consumer'
require 'consumers/package-manager-consumer'

TorqueBox::Messaging::Container::Config.create {
  consumers {
    map BoxGrinder::REST::ImageManagerConsumer, '/queues/boxgrinder/manage/image'
  }
}