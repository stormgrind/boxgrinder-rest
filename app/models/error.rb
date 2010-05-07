class Error
  def initialize( message, exception = nil )
    self.message = message
    self.exception = exception
  end

  attr_accessor :message
  attr_accessor :exception

  def info
    if @error.exception.nil?
      "#{@error.message}"
    else
      "#{@error.message}#$/#{@error.exception.backtrace.join($/)}"
    end
  end
end