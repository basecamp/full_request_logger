module FullRequestLogger
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env).tap { Processor.new(ActionDispatch::Request.new(env)).process }
    end
  end
end
