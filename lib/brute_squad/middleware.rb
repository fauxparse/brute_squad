module BruteSquad
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      Enforcer.process(@app, env)
    end
  end
end