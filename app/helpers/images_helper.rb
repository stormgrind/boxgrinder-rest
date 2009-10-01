module ImagesHelper
  include BaseHelper

  private

  def is_image_format?( format )
    return false if @image.image_format.nil?
    @image.image_format.eql?( Image::FORMATS[ format ] )
  end

  # TO REVIEW

  def is_image_in_progress?
    return true if @image.status.eql?( Image::STATUSES[:building] ) or @image.status.eql?( Image::STATUSES[:converting] ) or @image.status.eql?( Image::STATUSES[:packaging] )
    false
  end

  def is_image_status?( status )
    return false if @image.status.nil?
    @image.status.eql?( Image::STATUSES[status] )
  end

  def image_valid?
    return true unless is_image_status?( :error )
    render_error( @error )
    false
  end

  def image_loaded?( id )
    if id.nil? or !id.match(/\d+/)
      render_error(Error.new( "Invalid image id provided: #{id}" ))
      return false
    end

    begin
      @image = Image.find( id )
      return true
    rescue ActiveRecord::RecordNotFound => e
      render_error(Error.new( "Image with id = #{id} not found.", e ))
    rescue => e
      render_error( Error.new( "Unexpected error while retrieving image with id = #{id}.", e ))
    end
    false
  end


end
