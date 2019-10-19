require_relative "../test/dummy/config/environment"
require "rails/test_help"

require "full_request_logger"

class RecorderTest < ActiveSupport::TestCase
  setup do
    @logger = Logger.new(StringIO.new)
    @full_request_logger = FullRequestLogger::Recorder.new.tap { |frl| frl.attach_to(@logger) }
  end

  teardown { @full_request_logger.reset }

  test "attached frl will store writes made to logger" do
    @logger.info "This is a line"
    assert @full_request_logger.combined_log.include?("This is a line")
  end

  test "store combined log in single request log" do
    @logger.info "This is an extra line"
    @logger.info "This is another line"
    @logger.info "This is yet another line"

    @full_request_logger.store("123")

    assert_equal "This is an extra line\nThis is another line\nThis is yet another line", @full_request_logger.retrieve("123")
  end

  test "retrieve missing request" do
    assert_nil @full_request_logger.retrieve("not-there")
  end
end
