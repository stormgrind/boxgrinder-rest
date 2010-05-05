require 'consumers/image-manager-consumer'
require 'consumers/node-manager-consumer'

TorqueBox::Messaging::Container::Config.create {
  consumers {
    map BoxGrinder::REST::NodeManagerConsumer, '/queues/boxgrinder/manage/node'
    map BoxGrinder::REST::ImageManagerConsumer, '/queues/boxgrinder/manage/image'
  }
}