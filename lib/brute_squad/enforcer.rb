require "rack/utils"

module BruteSquad
  class Enforcer
    attr_accessor :env, :request
    
    def initialize(app, env)
      @app, @env = app, env
      @request = Rack::Request.new(@env)
      @env[:brute_squad] = self
    end
    
    def process
      result = catch :brute_squad do
        prepare
        status, headers, response = @app.call(env)
      end
      
      if Hash === result
        method = result.delete :method
        send method, result
      else
        result
      end
    end
    def self.process(app, env); new(app, env).process; end
    
    def method_missing(sym, *args)
      case sym.to_s
      when /^current_(.*)$/ then current($1.to_sym)
      else
        super
      end
    end
    
    def authorize!(model, id)
      
    end
    
    def redirect!(new_location = "/", options = {})
      throw :brute_squad, options.merge(:method => :redirect, :location => new_location)
    end
    
  protected
    def prepare
      BruteSquad.each do |name, model|
        model.prepare_request self
      end
    end
    
    def current(model)
      nil
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