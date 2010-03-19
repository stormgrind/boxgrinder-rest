class BaseController < ApplicationController

end

module ActiveSupport
  class BufferedLogger
    def add(severity, message = nil, progname = nil, &block)
      return if @level > severity
      message = (message || (block && block.call) || progname).to_s

      level = {
              0 => "DEBUG",
              1 => "INFO",
              2 => "WARN",
              3 => "ERROR",
              4 => "FATAL"
      }[severity] || "U"

      message = "[%s:\t%s #%d] %s" % [level,
                                      Time.now.strftime("%m%d %H:%M:%S"),
                                      $$,
                                      message]

      message = "#{message}\n" unless message[-1] == ?\n
      buffer << message
      auto_flush
      message
    end
  end
end