module ImagesHelper
  def image_actions
    a = []
    for method in ImagesController.instance_methods(false)
      a.push method unless method.eql?('index')
    end
    a.sort
  end
end
