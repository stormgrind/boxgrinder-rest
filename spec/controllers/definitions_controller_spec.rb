require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DefinitionsController do
  integrate_views

  fixtures :tasks, :definitions

  def tasks_fixtures_size
    1
  end

  it "should create a new definition" do
    Definition.count.should == 2
    post 'create'
    Definition.count.should == 3

    definition = assigns[:definition]

    definition.should_not == nil
    definition.status.should eql(Definition::STATUSES[:new])
    definition.description.should eql("Definition.")

    response.should render_template('definitions/show')
  end

  it "should delete a definition" do
    Definition.count.should == 2
    delete 'destroy', :id => 1
    Definition.count.should == 1

    definition = assigns[:definition]

    definition.should_not == nil
    definition.status.should eql(Definition::STATUSES[:removed])
    definition.description.should eql("This is a description of a definition")

    response.should render_template('definitions/show')
  end

  it "should render an error because definition with id = 123 doesn't exists" do
    Task.all.size.should == tasks_fixtures_size
    get 'show', :id => 123
    response.should render_template('root/error')
  end

  it "should render an error because of unexpected error" do
    Task.all.size.should == tasks_fixtures_size
    Definition.should_receive(:find).with("1").and_throw( "ERROR!")
    get 'show', :id => 1
    response.should render_template('root/error')
  end

  it "should display a definition" do
    definition = mock_model(Definition, :status => Definition::STATUSES[:created], :description => "desc", :created_at => Time.now, :updated_at => Time.now)
    Definition.should_receive(:find).with("1").and_return(definition)
    get 'show', :id => 1
    assigns[:definition].status.should eql(Definition::STATUSES[:created])
    response.should render_template('definitions/show')
  end

  it "should return a list of definitions" do
    get 'index'
    assigns[:definitions].size.should == 2
    response.should render_template('definitions/index')
  end

end
