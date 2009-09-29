require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Image do
  fixtures :images

  it "should be in state BUILDING" do
    image = Image.find(1)
    image.status.eql?(Defaults::IMAGE_STATUSES[:building])
  end
end
