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
      sessions = {}
      
      result = catch :brute_squad do
        sessions = prepare_sessions env
        env["brute_squad"] = sessions
        @app.call(env)
      end
      
      if Hash === result
        method = result.delete :method
        result = send method, result
      end

      sessions.inject(result) { |result, (_, session)| session.commit(*result) }
    end
    
  protected
    class Collection < HashWithIndifferentAccess
      def method_missing(sym, *args)
        if key?(sym)
          self[sym]
        else
          super
        end
      end
    end
  
    def prepare_sessions(env)
      BruteSquad.models.inject(Collection.new) do |h, (name, model)|
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
        [ params[:message] || "You are being redirected." ]
      ]
    end
    
    def deny(params = {})
      # TODO: send WWW-Authenticate header if appropriate
      [
        params[:status] || 401,
        { },
        [ params[:message] || "Authentication required." ]
      ]
    end
  end
end