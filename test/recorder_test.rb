require 'active_support'
require 'active_support/testing/autorun'

require 'full_request_logger'
require 'full_request_logger/recorder'
require 'full_request_logger/engine'

require 'redis' # is this desired? (or a mock/fake?)

class RecorderTest < ActiveSupport::TestCase
  setup do
    FullRequestLogger.redis = {
      host: "127.0.0.1",
      port: 6379
    }
  end

  test "a recorder can write and read messages" do
    recorder = FullRequestLogger::Recorder.instance

    message = "a log message!"
    another_message = "another message"
    recorder.write(message)
    recorder.write(another_message)

    assert recorder.log.include?(message)
    assert recorder.log.include?(another_message)
    assert_not recorder.log.include?("different message")
    assert_equal "a log message!another message", recorder.log
  end
end
