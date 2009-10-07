module BaseCommand
  def logger
    Rails.logger
  end

  def save_object(o)
    if o.id.nil?
      logger.info "Creating new #{o.class}..."
    else
      logger.info "Saving #{o.class} with id = #{o.id}..."
    end

    begin
      ActiveRecord::Base.transaction do
        o.save!
      end
    rescue => e
      logger.error "Could not save #{o.class} with id = #{o.id}"
      return false
    end

    logger.info "#{o.class} saved (id = #{o.id})."
    true
  end

end