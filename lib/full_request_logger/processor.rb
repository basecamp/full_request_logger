require "full_request_logger/recorder"
require "action_dispatch/http/request"

class FullRequestLogger::Processor
  def initialize(env)
    @env = env
  end

  def process
    if enabled? && eligible_for_storage?
      recorder.store request_id
    else
      recorder.clear
    end
  end

  private
    def enabled?
      FullRequestLogger.enabled
    end

    def eligible_for_storage?
      if eligibility.respond_to?(:call)
        eligibility.call(request)
      else
        eligibility
      end
    end

    delegate :eligibility, to: FullRequestLogger

    def recorder
      @recorder ||= FullRequestLogger::Recorder.instance
    end

    delegate :request_id, to: :request

    def request
      @request ||= ActionDispatch::Request.new(@env)
    end
end
