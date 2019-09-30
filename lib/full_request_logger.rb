require "full_request_logger/engine"

module FullRequestLogger
  extend ActiveSupport::Autoload

  autoload :Recorder

  mattr_accessor :ttl, default: 10.minutes
end
