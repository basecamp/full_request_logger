require_relative "../test/dummy/config/environment"
require "rails/test_help"

require "full_request_logger"

class RecorderEsTest < ActiveSupport::TestCase
  setup do
    FullRequestLogger::Recorder.reset_instance_cache!
    FullRequestLogger.data_adapter = FullRequestLogger::DataAdapters::ElastisearchAdapter
    @logger = Logger.new(StringIO.new)
    @full_request_logger = FullRequestLogger::Recorder.new.tap { |frl| frl.attach_to(@logger) }
  end

  teardown { @full_request_logger.clear_all }

  test "attached frl will store writes made to logger" do
    @logger.info "This is a line"
    assert @full_request_logger.combined_log.include?("This is a line")
  end

  test "store combined log in single request log" do
    @logger.info "This is an extra line"
    @logger.info "This is another line"
    @logger.info "This is yet another line"

    @full_request_logger.store("123")

    # Refresh to wait some time to reflex
    @full_request_logger.send(:data_adapter).send(:repository).refresh_index!
    assert_equal "This is an extra line\nThis is another line\nThis is yet another line", @full_request_logger.retrieve("123").body
  end

  test "retrieve missing request" do
    assert_nil @full_request_logger.retrieve("not-there")
  end

  test "store multiple request and get all" do
    @logger.info "This first log"
    @full_request_logger.store("first")

    @logger.info "This second log"
    @full_request_logger.store("second")

    # Refresh to wait some time to reflex
    @full_request_logger.send(:data_adapter).send(:repository).refresh_index!
    assert_equal @full_request_logger.retrive_list.size, 2
  end
end
