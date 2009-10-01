require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Image do
  fixtures :images

  it "should be in state BUILDING" do
    image = Image.find(1)
    image.status.eql?(Image::STATUSES[:building])
  end
end
