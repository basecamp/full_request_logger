module FullRequestLogger
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env).tap { Processor.new(env).process }
    end
  end
end
