require "full_request_logger/recorder"
require "action_dispatch/http/request"

class FullRequestLogger::Processor
  def initialize(env)
    @env = env
  end

  def process
    if enabled? && eligible_for_storage?
      store request_id
    else
      clear
    end
  end

  private
    def enabled?
      FullRequestLogger.enabled
    end

    def eligible_for_storage?
      if FullRequestLogger.eligibility.respond_to?(:call)
        FullRequestLogger.eligibility.call(request)
      else
        FullRequestLogger.eligibility
      end
    end

    delegate :store, :clear, to: :recorder
    def recorder
      @recorder ||= FullRequestLogger::Recorder.instance
    end

    delegate :request_id, to: :request
    def request
      @request ||= ActionDispatch::Request.new(@env)
    end
end
