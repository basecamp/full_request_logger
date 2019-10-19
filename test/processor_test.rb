require_relative "../test/dummy/config/environment"
require "rails/test_help"

require "full_request_logger"

FullRequestLogger.enabled = true
FullRequestLogger.eligibility = true

class ProcessorTest < ActiveSupport::TestCase
  LOGGER = Logger.new(StringIO.new)
  FRL    = FullRequestLogger::Recorder.instance.tap { |frl| frl.attach_to(LOGGER) }

  setup do
    @processor = FullRequestLogger::Processor.new({ "action_dispatch.request_id" => "123" })
  end

  teardown { FRL.clear_all }

  test "store when enabled with basic eligibility" do
    LOGGER.info "hello!"
    @processor.process
    assert FRL.combined_log.blank?
    assert_equal "hello!", FRL.retrieve("123")
  end

  test "clear without store when not enabled" do
    begin
      FullRequestLogger.enabled = false

      LOGGER.info "hello!"
      @processor.process
      assert FRL.combined_log.blank?
      assert_nil FRL.retrieve("123")
    ensure
      FullRequestLogger.enabled = true
    end
  end
end
