class Error
  def initialize( message, exception = nil )
    @message = message
    @exception = exception
  end

  attr_accessor :message
  attr_accessor :exception

  def info
    if @exception.nil?
      "#{@message}"
    else
      "#{@message}#$/#{@exception.backtrace.join($/)}"
    end
  end
end