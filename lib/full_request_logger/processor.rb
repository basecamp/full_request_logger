# frozen_string_literal: true

class FullRequestLogger::Processor
  def initialize(env)
    @env = env
  end

  def process
    if eligible_for_storage?
      store request_id
    else
      clear
    end
  end

  private
    def eligible_for_storage?
      true
    end

    delegate :store, :clear, to: :recorder
    def recorder
      @recorder ||= FullRequestLogger::Recorder.instance
    end

    delegate :request_id, to: :request
    def request
      @request ||= ActionDispatch::Request.new(env)
    end
end
