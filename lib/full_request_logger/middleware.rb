module FullRequestLogger
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env).tap do
        Recorder.instance.flush ActionDispatch::Request.new(env).request_id
      end
    end
  end
end