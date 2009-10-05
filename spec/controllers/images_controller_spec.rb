require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class ActionQueue
end

describe ImagesController do

  integrate_views
  fixtures :images

  def image_fixtures_size
    4
  end


  before(:each) do
    #$LOAD_PATH.reject!{|e| e =~ /queues/ }
    #ActionQueue.stub!(:enqueue).and_return(true)
  end

  it "should create a task to delete image with id = 1" do
    ActionQueue.should_receive(:enqueue)

    Image.count.should == image_fixtures_size
    delete 'destroy', :id => 1
    Image.count.should == image_fixtures_size

    image = assigns[:image]
    assigns[:error].should == nil
    image.should_not == nil
    image.status.should eql(Image::STATUSES[:removing])

    response.should render_template('images/show')
  end

  it "should receive list of images" do
    get 'index'

    images = assigns[:images]
    assigns[:error].should == nil

    images.size.should == image_fixtures_size

    response.should render_template('images/index')
  end

  it "should show selected image" do
    get 'show', :id => 1

    image = assigns[:image]
    assigns[:error].should == nil

    image.status.should eql(Image::STATUSES[:building])
    image.image_format.should eql(Image::FORMATS[:vmware])
    image.definition_id.should == 1

    response.should render_template('images/show')
  end

  it "should show selected image in yaml format" do
    request.env['HTTP_ACCEPT'] = "text/yaml"
    get 'show', :id => 1

    image = assigns[:image]
    assigns[:error].should == nil

    image.status.should eql(Image::STATUSES[:building])
    image.image_format.should eql(Image::FORMATS[:vmware])
    image.definition_id.should == 1

    response.body.should eql(image.attributes.to_yaml)
  end

  it "should not show selected image because there is no image with id = 123" do
    get 'show', :id => 123

    error = assigns[:error]
    error.should_not == nil
    error.message.should eql("Image with id = 123 not found.")

    response.should render_template('root/error')
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
    error.message.should eql("Invalid format speficied. Available formats: EC2, RAW, VMWARE.")

    response.should render_template('root/error')
  end

  it "should create a new image" do
    ActionQueue.should_receive(:enqueue)

    Image.count.should == image_fixtures_size
    post 'create', :definition_id => 2
    Image.count.should == image_fixtures_size + 1

    image = assigns[:image]
    image.should_not == nil
    assigns[:error].should == nil
    image.status.should eql(Image::STATUSES[:new])
    image.image_format.should eql(Image::FORMATS[:raw])
    image.definition_id.should == 2
    image.description.should eql("Image for definition id = 2 and RAW format.")

    response.should render_template('images/show')
  end

  it "should found existing image while creating a new image" do
    Image.count.should == image_fixtures_size
    post 'create', :definition_id => 1
    Image.count.should == image_fixtures_size

    image = assigns[:image]
    image.should_not == nil
    assigns[:error].should == nil
    image.status.should eql(Image::STATUSES[:created])
    image.image_format.should eql(Image::FORMATS[:raw])
    image.definition_id.should == 1
    image.description.should eql("This is a description of an image")

    response.should render_template('images/show')
  end

  it "should found existing image while converting image to EC2 format" do
    Image.count.should == image_fixtures_size
    post 'convert', :id => 2, :image_format => 'eC2'
    Image.count.should == image_fixtures_size

    image = assigns[:image]
    image.should_not == nil
    assigns[:error].should == nil
    image.id.should == 3
    image.status.should eql(Image::STATUSES[:error])
    image.image_format.should eql(Image::FORMATS[:ec2])
    image.definition_id.should == 1
    image.description.should eql("This is a description of an EC2 image")

    response.should render_template('images/show')
  end

  it "should convert image to EC2 format" do
    ActionQueue.should_receive(:enqueue)

    Image.count.should == image_fixtures_size
    post 'convert', :id => 4, :image_format => 'eC2'
    Image.count.should == image_fixtures_size + 1

    image = assigns[:image]
    image.should_not == nil
    assigns[:error].should == nil
    image.status.should eql(Image::STATUSES[:new])
    image.image_format.should eql(Image::FORMATS[:ec2])
    image.definition_id.should == 3
    image.description.should eql("Image for definition id = 3 and EC2 format.")

    response.should render_template('images/show')
  end

end
