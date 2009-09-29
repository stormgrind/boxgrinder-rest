class Error
  def initialize( message, exception = nil )
    self.message = message
    self.exception = exception
  end

  attr_accessor :message
  attr_accessor :exception
end