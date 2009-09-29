require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ImagesController do

  fixtures :images, :tasks

  it "should create a task for destroying an image with id = 1" do
    delete 'destroy', :id => 1

    task = assigns[:task]

    task.status.should eql(Defaults::TASK_STATUSES[:new])
    task.artifact.should eql(Defaults::ARTIFACTS[:image])
    task.action.should eql(Defaults::IMAGE_ACTIONS[:destroy])
    task.description.should eql("Destroing image with id = 1.")

    response.should render_template('tasks/show')
  end

  it "should not create an task to build image because there is no definition_id and return to error" do
    post 'create'

    response.should render_template('root/error')
  end

  it "should create a task for building new image" do
    post 'create', :definition_id => 1

    task = assigns[:task]

    task.status.should eql(Defaults::TASK_STATUSES[:new])
    task.artifact.should eql(Defaults::ARTIFACTS[:image])
    task.action.should eql(Defaults::IMAGE_ACTIONS[:build])
    task.description.should eql("Creating image from definition with id = 1.")

    response.should render_template('tasks/show')
  end

end
