require 'rubygems'
require 'active_record'

module BaseCommand
  Dir["#{File.dirname(__FILE__)}/../models/*.rb"].each {|file| require file }

  def logger
    Rails.logger
  end

  def execute_command( command )
    logger.debug "Executing command: '#{command}'"

    out = `#{command} 2>&1`

    formatted_output = "Command return:\r\n+++++\r\n#{out}+++++"

    if $?.to_i != 0
      logger.error formatted_output
      raise "An error occured executing command: '#{command}'"
    else
      logger.debug formatted_output unless out.strip.length == 0
      logger.debug "Command '#{command}' executed successfuly"
      return out
    end
  end

  def save_object(o)
    unless ActiveRecord::Base.connected?
      logger.error "No connection available, trying reconnect..."
      begin
        ActiveRecord::Base.establish_connection(YAML::load(File.open("#{RAILS_ROOT}/config/database.yml"))[RAILS_ENV.to_sym])
      rescue => e
        logger.fatal e
        raise e
      end
    end

    if o.id.nil?
      logger.info "Creating new #{o.class}..."
    else
      logger.info "Saving #{o.class} with id = #{o.id}..."
    end

    begin
      ActiveRecord::Base.transaction do
        o.save!
      end
      logger.info "#{o.class} saved (id = #{o.id})."
      return true
    rescue => e
      logger.error "Could not save #{o.class} with id = #{o.id}"
      logger.error e
      logger.error e.backtrace
      raise e
    end
  end

end