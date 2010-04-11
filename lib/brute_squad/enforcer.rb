require "rack/utils"

module BruteSquad
  class Enforcer
    attr_accessor :env, :request
    
    def initialize(app, options = {}, &block)
      @app = app
      @options = options
      BruteSquad.instance_eval &block if block_given?
    end
    
    def call(env)
      request = Rack::Request.new(env)

      result = catch :brute_squad do
        sessions = prepare_sessions env, request
        status, headers, response = @app.call(env)
      end
      
      if Hash === result
        method = result.delete :method
        send method, result
      else
        result
      end
    end
    
    def authorize!(model, id)
      
    end
    
    def redirect!(new_location = "/", options = {})
      throw :brute_squad, options.merge(:method => :redirect, :location => new_location)
    end
    
  protected
    def prepare_sessions(env, request)
      BruteSquad.models.inject({}) do |h, (name, model)|
        returning Session.new(self, model, env, request) do |session|
          h[name] = session
        end
        h
      end
    end
    
    def redirect(params)
      [
        params[:status] || 302,
        {
          "Location" => params[:location] || "/"
        },
        [ params[:message] || "You are being redirected" ]
      ]
    end
  end
end