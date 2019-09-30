require "rails/engine"
require "full_request_logger/middleware"

module FullRequestLogger
  class Engine < Rails::Engine
    isolate_namespace FullRequestLogger
    config.eager_load_namespaces << FullRequestLogger

    config.full_request_logger = ActiveSupport::OrderedOptions.new
    config.full_request_logger.redis = {}

    initializer "full_request_logger.middleware" do
      config.app_middleware.insert_after ::ActionDispatch::RequestId, FullRequestLogger::Middleware
    end

    initializer "full_request_logger.recoder_attachment" do
      config.after_initialize do
        FullRequestLogger::Recorder.instance.attach_to Rails.logger
      end
    end
  end
end
