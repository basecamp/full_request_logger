require "rails/engine"
require "full_request_logger/middleware"
require "full_request_logger/data_adapters/base_adapter"
require "full_request_logger/data_adapters/redis_adapter"
require "full_request_logger/job"

module FullRequestLogger
  class Engine < Rails::Engine
    isolate_namespace FullRequestLogger
    config.eager_load_namespaces << FullRequestLogger

    config.full_request_logger = ActiveSupport::OrderedOptions.new

    initializer "full_request_logger.middleware" do
      config.app_middleware.insert_after ::ActionDispatch::RequestId, FullRequestLogger::Middleware
    end

    initializer "full_request_logger.job" do
      ActiveSupport.on_load(:active_job) do
        include FullRequestLogger::Job
      end
    end

    initializer "full_request_logger.configs" do
      config.after_initialize do |app|
        FullRequestLogger.enabled       = app.config.full_request_logger.enabled || false
        FullRequestLogger.ttl           = app.config.full_request_logger.ttl   || 10.minutes
        FullRequestLogger.redis         = app.config.full_request_logger.redis || {}
        FullRequestLogger.eligibility   = app.config.full_request_logger.eligibility || true
        FullRequestLogger.data_adapter  = {
          redis: FullRequestLogger::DataAdapters::RedisAdapter
        }.fetch(app.config.full_request_logger.data_adapter, FullRequestLogger::DataAdapters::RedisAdapter)

        FullRequestLogger.credentials   = app.config.full_request_logger.credentials || app.credentials.full_request_logger
      end
    end

    initializer "full_request_logger.recoder_attachment" do
      config.after_initialize do |app|
        if app.config.full_request_logger.enabled
          FullRequestLogger::Recorder.instance.attach_to Rails.logger
        end
      end
    end
  end
end
