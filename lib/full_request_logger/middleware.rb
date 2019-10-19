module FullRequestLogger
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env).tap { Processor.process(env) }
    end
  end
end
