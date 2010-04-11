require "rack/utils"

module BruteSquad
  class Enforcer
    attr_accessor :env
    
    def initialize(app, options = {}, &block)
      @app = app
      @options = options
      BruteSquad.instance_eval &block if block_given?
    end
    
    def call(env)
      sessions = []

      result = catch :brute_squad do
        sessions = prepare_sessions env
        @app.call(env)
      end
      
      status, headers, response = if Hash === result
        method = result.delete :method
        send method, result
      else
        result
      end

      sessions.values.inject(result) { |result, session| session.commit(*result) }
    end
    
    def authorize!(model, id)
      
    end
    
    def redirect!(new_location = "/", options = {})
      throw :brute_squad, options.merge(:method => :redirect, :location => new_location)
    end
    
  protected
    def prepare_sessions(env)
      BruteSquad.models.inject({}) do |h, (name, model)|
        returning Session.new(self, model, env) do |session|
          h[name] = session
        end
        h
      end
    end
    
    def redirect(params)
      [
        params[:status] || 302,
        { "Location" => params[:location] || "/" },
        [ params[:message] || "You are being redirected" ]
      ]
    end
  end
end