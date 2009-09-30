require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ImagesController do

  fixtures :images, :tasks

  it "should delete image with id = 1" do
    Image.count.should == 3
    delete 'destroy', :id => 1
    Image.count.should == 2

    image = assigns[:image]

    image.should_not == nil
    image.status.should eql(Image::STATUS[:removed])

    response.should render_template('images/show')
  end

  it "should not create an task to build image because there is no definition_id and return to error" do
    post 'create'

    response.should render_template('root/error')
  end

  it "should create a new image" do
    Image.count.should == 3
    post 'create', :definition_id => 1
    Image.count.should == 4
  
    image = assigns[:image]

    image.should_not == nil
    image.status.should eql(Image::STATUS[:new])
    image.image_format.should eql(Image::FORMAT[:raw])
    image.definition_id.should == 1
    image.description.should eql("Image for definition id = 1 and RAW format.")

    response.should render_template('images/show')
  end

end
