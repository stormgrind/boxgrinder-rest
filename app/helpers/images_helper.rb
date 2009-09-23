module ImagesHelper
  def is_in_progress?
    return true if @image.status.nil?
    @image.status.eql?('BUILDING') or @image.status.eql?('PACKAGING')
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
