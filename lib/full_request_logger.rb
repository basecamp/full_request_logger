require "full_request_logger/engine"

module FullRequestLogger
  extend ActiveSupport::Autoload

  autoload :Recorder
  autoload :Processor

  mattr_accessor :ttl
  mattr_accessor :redis
  mattr_accessor :enabled
  mattr_accessor :eligibility
  mattr_accessor :credentials
end
