require "full_request_logger/recorder"

class FullRequestLogger::Processor
  def initialize(request)
    @request = request
  end

  def process
    if enabled? && eligible_for_storage?
      recorder.store request_id
    else
      recorder.clear
    end
  end

  private
    attr_reader :request
    delegate :request_id, to: :request

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
end
