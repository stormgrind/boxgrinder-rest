module ImagesHelper

  include Defaults

  def is_in_progress?
    return true if @image.status.nil?
    @image.status.eql?( IMAGE_STATUS[:building] ) or @image.status.eql?( IMAGE_STATUS[:packaging] )
  end

  def is_building?
    return false if @image.status.nil?
    @image.status.eql?( IMAGE_STATUS[:building] )
  end

  def is_built?
    return false if @image.status.nil?
    @image.status.eql?( IMAGE_STATUS[:built] )
  end

  def is_packaged?
    return false if @image.status.nil?
    @image.status.eql?( IMAGE_STATUS[:packaged] )
  end

  def is_new?
    return true if @image.status.nil?
    @image.status.eql?( IMAGE_STATUS[:new] )
  end

   def is_invalid?
    return true if @image.status.nil?
    @image.status.eql?( IMAGE_STATUS[:invalid] )
  end
end
