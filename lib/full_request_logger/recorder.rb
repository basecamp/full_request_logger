# frozen_string_literal: true

require "zlib"

class FullRequestLogger::Recorder
  attr_reader :redis

  def self.instance
    @instance ||= new
  end

  def initialize
    @redis = Redis.new FullRequestLogger.redis
  end

  def attach_to(logger)
    logger.extend ActiveSupport::Logger.broadcast(
      ActiveSupport::Logger.new(self)
    )
  end

  def write(message)
    messages << remove_ansi_colors(message)
  end

  def log
    messages.join.strip
  end

  def flush(request_id)
    if (log_to_be_flushed = log).present?
      redis.setex \
        request_key(request_id),
        FullRequestLogger.ttl,
        compress(log_to_be_flushed)
    end
  ensure
    messages.clear
  end

  def retrieve(request_id)
    if log = retrieve_from_redis(request_id)
      uncompress(log).force_encoding("utf-8")
    end
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

    def retrieve_from_redis(request_id)
      redis.get(request_key(request_id))
    end

    def request_key(id)
      "full_request_logger/requests/#{id}"
    end

    def compress(text)
      Zlib::Deflate.deflate(text)
    end

    def uncompress(text)
      Zlib::Inflate.inflate(text)
    end
end
