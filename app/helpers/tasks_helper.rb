module TasksHelper
  def task_actions
    a = []
    for method in TasksController.instance_methods(false)
      a.push method unless method.eql?('index')
    end
    a.sort
  end
end
