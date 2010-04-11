module BruteSquad
  class Session
    attr_reader :enforcer, :model, :env, :request
    
    def initialize(enforcer, model, env, request)
      @enforcer, @model, @env, @request = enforcer, model, env, request
      @values, @persistence = request.cookies.dup, {}
      
      model.prepare self
      env[key] = self
    end
    
    def [](key)
      @values["#{self.key}.#{key}"]
    end
    
    def []=(key, value)
      set key, value, false
    end
    
    def set(key, value, persist = false)
      @values["#{self.key}.#{key}"] = value
      @persistence["#{self.key}.#{key}"] = persist if persist
    end
    
    def current
      @current ||= fetch
    end
    
    def key
      "brute_squad.#{model}"
    end
    
    def authenticate!(instance, persist = false)
      set :current, model.authentication_for(instance), persist
    end
    
    def redirect!(new_location = "/", options = {})
      enforcer.redirect! new_location, options
    end
    
  protected
    def fetch
      auth_params = model.authentication_keys.inject({}) do |h, k|
        return nil unless h[k] = self[k]
        h
      end
      model.find_for_authentication auth_params
    end
  end
end