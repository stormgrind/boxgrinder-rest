require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class ActionQueue
end

describe ImagesController do

  fixtures :images

  before(:each) do
    #$LOAD_PATH.reject!{|e| e =~ /queues/ }
    #ActionQueue.stub!(:enqueue).and_return(true)
  end

  it "should create a task to delete image with id = 1" do
    ActionQueue.should_receive(:enqueue)

    Image.count.should == 3
    delete 'destroy', :id => 1
    Image.count.should == 3

    image = assigns[:image]
    assigns[:error].should == nil
    image.should_not == nil
    image.status.should eql(Image::STATUSES[:removing])

    response.should render_template('images/show')
  end

  it "should not create a task to build image because there is no definition_id and return to error" do
    post 'create'

    error = assigns[:error]
    error.should_not == nil
    error.message.should eql("No or not valid definition_id parameter specified.")

    response.should render_template('root/error')
  end

  it "should not create a task to build image because of invalid image format" do
    post 'create', :definition_id => 1, :image_format => "strange_format"

    error = assigns[:error]
    error.should_not == nil
    error.message.should eql("Invalid format speficied. Available formats: RAW, VMWARE, EC2.")

    response.should render_template('root/error')
  end

  it "should create a new image" do
    ActionQueue.should_receive(:enqueue)

    Image.count.should == 3
    post 'create', :definition_id => 2
    Image.count.should == 4

    image = assigns[:image]
    image.should_not == nil
    assigns[:error].should == nil
    image.status.should eql(Image::STATUSES[:new])
    image.image_format.should eql(Image::FORMATS[:raw])
    image.definition_id.should == 2
    image.description.should eql("Image for definition id = 2 and RAW format.")

    response.should render_template('images/show')
  end

end
