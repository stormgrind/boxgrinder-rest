module ImagesHelper
  include BaseHelper

  private

  def is_image_format?( type )
    return false if @image.type.nil?
    @image.type.eql?( type )
  end

  #OLD

  def is_image_in_progress?
    return true if @image.status.eql?( IMAGE_STATUSES[:building] ) or @image.status.eql?( IMAGE_STATUSES[:converting] ) or @image.status.eql?( IMAGE_STATUSES[:packaging] )
    false
  end

  def is_image_status?( status )
    return false if @image.status.nil?
    @image.status.eql?( IMAGE_STATUSES[status] )
  end

  def image_valid?
    return true unless is_image_status?( :invalid )

    render_error( @error )
    false
  end

  def image_loaded?( id )
    return false if id.nil? or !id.match(/\d+/)
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

  def render_archive
    head :not_found

    if is_image_status?( :packaged )
      #send_file 'aaa', :type => 'application/zip'
    else
      # if it is not packaged: head :not_found
      #head :multiple_choices, :location => [ "#{image_path}.tar" ]
    end
  end
end
