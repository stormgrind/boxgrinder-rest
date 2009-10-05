require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DefinitionsController do
  integrate_views

  fixtures :definitions

  def definition_fixtures_size
    3
  end

  it "should not create a new definition because there is no definition file in request" do
    Definition.count.should == definition_fixtures_size
    post 'create'
    Definition.count.should == definition_fixtures_size

    error = assigns[:error]

    error.should_not == nil
    error.message.should eql("No definition parameter specified in your request.")

    response.should render_template('root/error')
  end

  #definition = assigns[:definition]
  #definition.should_not == nil
  #definition.status.should eql(Definition::STATUSES[:new])
  #definition.description.should eql("Definition.")
  #response.should render_template('definitions/show')

  it "should delete a definition" do
    Definition.count.should == definition_fixtures_size
    delete 'destroy', :id => 1
    Definition.count.should == definition_fixtures_size - 1

    definition = assigns[:definition]

    definition.should_not == nil
    definition.status.should eql(Definition::STATUSES[:removed])
    definition.description.should eql("This is a description of a definition")

    response.should render_template('definitions/show')
  end

  it "should render an error because definition with id = 123 doesn't exists" do
    get 'show', :id => 123
    response.should render_template('root/error')
  end

  it "should render an error because of unexpected error" do
    Definition.should_receive(:find).with("1").and_throw( "ERROR!")
    get 'show', :id => 1
    response.should render_template('root/error')
  end

  it "should display a definition" do
    definition = mock_model(Definition, :status => Definition::STATUSES[:created], :description => "desc", :created_at => Time.now, :updated_at => Time.now, :file => "/this/is/a/file")
    Definition.should_receive(:find).with("1").and_return(definition)
    get 'show', :id => 1
    assigns[:definition].status.should eql(Definition::STATUSES[:created])
    response.should render_template('definitions/show')
  end

  it "should return a list of definitions" do
    get 'index'
    assigns[:definitions].size.should == definition_fixtures_size
    response.should render_template('definitions/index')
  end

end
