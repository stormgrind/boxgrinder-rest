require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DefinitionsController do
  integrate_views

  fixtures :tasks, :definitions

  def tasks_fixtures_size
    1
  end

  it "should create a new task for creating new definition" do
    Task.all.size.should == tasks_fixtures_size
    post 'create'
    Task.all.size.should == tasks_fixtures_size + 1

    task = Task.last

    task.status.should eql(Defaults::TASK_STATUSES[:new])
    task.artifact.should eql(Defaults::ARTIFACTS[:definition])
    task.action.should eql(Defaults::DEFINITION_ACTIONS[:create])

    response.should render_template('tasks/show')
  end

  it "should create a new task for deleting definition" do
    Task.all.size.should == tasks_fixtures_size
    delete 'destroy', :id => 1
    Task.all.size.should == tasks_fixtures_size + 1

    task = Task.last

    task.status.should eql(Defaults::TASK_STATUSES[:new])
    task.artifact.should eql(Defaults::ARTIFACTS[:definition])
    task.artifact_id.should == 1
    task.action.should eql(Defaults::DEFINITION_ACTIONS[:destroy])

    response.should render_template('tasks/show')
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
    definition = mock_model(Definition, :status => Defaults::DEFINITION_STATUSES[:created], :description => "desc", :created_at => Time.now, :updated_at => Time.now)
    Definition.should_receive(:find).with("1").and_return(definition)
    get 'show', :id => 1
    assigns[:definition].status.should eql(Defaults::DEFINITION_STATUSES[:created])
    response.should render_template('definitions/show')
  end

  it "should return a list of definitions" do
    get 'index'
    assigns[:definitions].size.should == 2
    response.should render_template('definitions/index')
  end

end
