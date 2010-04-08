module BruteSquad
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      dup._call(env)
    end

  protected
    def _call(env) #:nodoc:
      @app.call(env)
    end
  end
end