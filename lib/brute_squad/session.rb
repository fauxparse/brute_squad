module BruteSquad
  class Session
    attr_reader :enforcer, :env, :request
    
    def initialize(enforcer, env, request)
      @enforcer, @env, @request = enforcer, env, request
      @values, @persistence = request.cookies.dup, {}
    end
    
    def [](key)
      @values[key]
    end
    
    def []=(key, value)
      set key, value, false
    end
    
    def set(key, value, persist = false)
      @values[key] = value
      @persistence[key] = persist if persist
    end
    
    def redirect!(new_location = "/", options = {})
      enforcer.redirect! new_location, options
    end
  end
end