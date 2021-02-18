require_relative "../test/dummy/config/environment"
require "rails/test_help"

require "full_request_logger"

FullRequestLogger.enabled = true
FullRequestLogger.eligibility = true

class ProcessorRedisTest < ActiveSupport::TestCase
  setup do
    FullRequestLogger::Recorder.reset_instance_cache!
    FullRequestLogger.data_adapter = FullRequestLogger::DataAdapters::RedisAdapter
    @logger = Logger.new(StringIO.new)
    @full_request_logger = FullRequestLogger::Recorder.new.tap { |frl| frl.attach_to(@logger) }
    @processor = FullRequestLogger::Processor.new(ActionDispatch::Request.new({ "action_dispatch.request_id" => "123" }))
  end

  teardown { @full_request_logger.clear_all }

  test "store when enabled with basic eligibility" do
    @logger.info "hello!"
    @processor.process
    assert @full_request_logger.combined_log.blank?
    assert_equal "hello!", @full_request_logger.retrieve("123").body
  end

  test "clear without store when not enabled" do
    begin
      FullRequestLogger.enabled = false

      @logger.info "hello!"
      @processor.process
      assert @full_request_logger.combined_log.blank?
      assert_nil @full_request_logger.retrieve("123")
    ensure
      FullRequestLogger.enabled = true
    end
  end

  test "successful eligibility will store request" do
    begin
      FullRequestLogger.eligibility = ->(request) { request.request_id == "123" }

      @logger.info "hello!"
      @processor.process
      assert @full_request_logger.combined_log.blank?
      assert_equal "hello!", @full_request_logger.retrieve("123").body
    ensure
      FullRequestLogger.eligibility = true
    end
  end

  test "failing eligibility will not store request" do
    begin
      FullRequestLogger.eligibility = ->(request) { request.request_id == "678" }

      @logger.info "hello!"
      @processor.process
      assert @full_request_logger.combined_log.blank?
      assert_nil @full_request_logger.retrieve("123")
    ensure
      FullRequestLogger.eligibility = true
    end
  end
end
