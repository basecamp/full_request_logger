# frozen_string_literal: true
require "zlib"

class FullRequestLogger::Recorder
  def self.instance
    @instance ||= new
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
      data_adapter.write(key: request_id, ttl: FullRequestLogger.ttl, text: compress(log_to_be_stored))
    end
  ensure
    clear
  end

  # Returns a single string with all the log messages that were captured for the given +request_id+ (or nil if nothing was
  # recorded or it has since expired).
  def retrieve(request_id)
    if log = data_adapter.find(request_id)
      uncompress(log).force_encoding("utf-8")
    end
  end

  # Returns the list of logs with request_id to show at index, supports for basic next page and search
  def retrive_list(page: 1, per_page: 50, query: nil)
    data_adapter.all(page: 1, per_page: 50, query: nil)
  end

  # Clears the current buffer of log messages.
  def clear
    messages.clear
  end

  # Clear out any messages pending in the buffer as well as all existing stored request logs.
  def clear_all
    clear
    clear_stored_requests
  end

  # no-op needed for Logger to treat this as a valid log device
  def close
    data_adapter.close
  end

  private

  def data_adapter
    @data_adapter ||= FullRequestLogger.data_adapter.object
  end

  def messages
    Thread.current[:full_request_logger_messages] ||= []
  end

  def remove_ansi_colors(message)
    message.remove(/\e\[\d+m/)
  end

  def clear_stored_requests
    data_adapter.clear
  end

  def compress(text)
    Zlib::Deflate.deflate(text)
  end

  def uncompress(text)
    Zlib::Inflate.inflate(text)
  end
end
