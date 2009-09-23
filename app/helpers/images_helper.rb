module ImagesHelper
  def image_actions
    a = []
    for method in ImagesController.instance_methods(false)
      a.push method unless method.eql?('index')
    end
    a.sort
  end

  def is_built?
    return false if @image.status.nil?
    @image.status.eql?('BUILT')
  end

  def is_packaged?
    return false if @image.status.nil?
    @image.status.eql?('PACKAGED')
  end
end
