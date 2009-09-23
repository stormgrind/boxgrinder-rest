module ImagesHelper
  def is_built?
    return false if @image.status.nil?
    @image.status.eql?('BUILT')
  end

  def is_packaged?
    return false if @image.status.nil?
    @image.status.eql?('PACKAGED')
  end
end
