# frozen_string_literal: true

require "redis"
require "zlib"

class FullRequestLogger::Recorder
  attr_reader :redis

  def self.instance
    @instance ||= new
  end

  def initialize
    @redis = Redis.new FullRequestLogger.redis
  end

  # Extends an existing logger instance with a broadcast aspect that'll send a copy of all logging lines to this recorder.
  def attach_to(logger)
    logger.extend ActiveSupport::Logger.broadcast(ActiveSupport::Logger.new(self))
  end

  # Writes a log message to a buffer that'll be stored when the request is over.
  def write(message)
    messages << remove_ansi_colors(message)
  end

  # Return a single string with all the log messages that have been buffered so far.
  def combined_log
    messages.join.strip
  end

  # Store all log messages as a single string to the full request logging storage accessible under the +request_id+.
  def store(request_id)
    if (log_to_be_stored = combined_log).present?
      redis.setex \
        request_key(request_id),
        FullRequestLogger.ttl,
        compress(log_to_be_stored)
    end
  ensure
    messages.clear
  end

  # Returns a single string with all the log messages that were captured for the given +request_id+ (or nil if nothing was
  # recorded or it has since expired).
  def retrieve(request_id)
    if log = redis.get(request_key(request_id))
      uncompress(log).force_encoding("utf-8")
    end
  end

  # Clear out any messages pending in the buffer as well as all existing stored request logs.
  def reset
    messages.clear
    clear_stored_requests
  end

  # no-op needed for Logger to treat this as a valid log device
  def close
    redis.disconnect!
  end

  private
    def messages
      Thread.current[:full_request_logger_messages] ||= []
    end

    def remove_ansi_colors(message)
      message.remove(/\e\[\d+m/)
    end

    def request_key(id)
      "full_request_logger/requests/#{id}"
    end

    def clear_stored_requests
      if (request_keys = redis.keys(request_key("*"))).any?
        redis.del request_keys
      end
    end

    def compress(text)
      Zlib::Deflate.deflate(text)
    end

    def uncompress(text)
      Zlib::Inflate.inflate(text)
    end
end
