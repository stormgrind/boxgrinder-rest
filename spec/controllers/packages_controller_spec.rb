require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PackagesController do

  fixtures :packages

  def packages_fixtures_size
    2
  end

  it "should render a list of packages" do
    get 'index'

    packages = assigns[:packages]
    assigns[:error].should == nil

    packages.size.should == packages_fixtures_size

    response.should render_template('packages/index')
  end

  it "should show package with id = 1" do
    get 'show', :id => 1

    package = assigns[:package]
    assigns[:error].should == nil

    package.status.should eql(Package::STATUSES[:created])
    package.description.should eql("This is a package number one.")

    response.should render_template('packages/show')
  end

  it "should render error because package with id = 134 doesn't exists" do
    get 'show', :id => 134

    error = assigns[:error]
    assigns[:package].should == nil
    error.should_not == nil

    error.message.should eql("Package with id = 134 not found.")

    response.should render_template('root/error')
  end

end
