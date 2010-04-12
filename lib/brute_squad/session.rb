require "openssl"

module BruteSquad
  class Session
    attr_reader :enforcer, :model, :env, :request, :values, :errors
    
    def initialize(enforcer, model, env)
      @request = Rack::Request.new(env)
      @enforcer, @model, @env = enforcer, model, env
      @values, @keys_to_persist = HashWithIndifferentAccess.new, Set.new
      @errors = []

      @key    = "brute_squad.#{model}.session"
      @secret = model.session_secret
      @default_options = {
        :domain       => model.session_domain,
        :path         => "/",
        :expire_after => model.session_expiry
      }
            
      load
      model.prepare self
      env["brute_squad.#{model}"] = self
    end
    
    def auth
      @auth_request ||= AuthRequest.new(@env)
    end
    
    def [](key)
      values[key.to_sym]
    end
    
    def []=(key, value)
      set key, value, false
    end
    
    def set(key, value, persist = false)
      @values[key.to_sym] = value
      @keys_to_persist << key.to_sym if persist
    end
    
    def candidate(params = nil)
      if params
        @candidate = model.find_for_authentication params
      end
      @candidate
    end
    
    def current
      @current ||= fetch self[:current]
    end
    
    def logged_in?
      current.present?
    end
    
    def authenticate!(instance, persist = false)
      @current = instance
      set :current, model.authentication_for(instance), persist
    end
    
    def fail!(message)
      @errors << []
    end
    
    def redirect!(new_location = "/", options = {})
      throw :brute_squad, options.merge(:method => :redirect, :location => new_location)
    end
    
    def persist?
      !@keys_to_persist.empty?
    end
  
    def load
      session_data = request.cookies[@key]
      
      if @secret && session_data
        session_data, digest = session_data.split("--")
        session_data = nil  unless digest == generate_hmac(session_data)
      end

      begin
        session_data = session_data.unpack("m*").first
        session_data = Marshal.load(session_data)
        @values = session_data.with_indifferent_access
      rescue
        @values = HashWithIndifferentAccess.new
      end
      
      @values.update @request.params
      
      persisted_keys = @values.keys.to_set
    end

    def commit(status, headers, body)
      if persist?
        session_data = Marshal.dump(values_to_persist)
        session_data = [session_data].pack("m*")

        if @secret
          session_data = "#{session_data}--#{generate_hmac(session_data)}"
        end

        if session_data.size > (4096 - @key.size)
          env["brute_squad.errors"].puts("Brute Squad cookie data size exceeds 4K. Content dropped.")
        else
          options = @default_options
          cookie = Hash.new
          cookie[:value] = session_data
          cookie[:expires] = Time.now + options[:expire_after] unless options[:expire_after].nil?
          Rack::Utils.set_cookie_header!(headers, @key, cookie.merge(options))
        end
      end

      [status, headers, body]
    end

  protected
    class AuthRequest < ::Rack::Auth::AbstractRequest
      def basic?
        :basic == scheme
      end

      def credentials
        @credentials ||= params.unpack("m*").first.split(/:/, 2)
      end

      def username
        credentials.first
      end
    end
  
    def values_to_persist
      @keys_to_persist.inject({}) do |h, k|
        h[k] = values[k]
      end
    end

    def generate_hmac(data)
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, @secret, data)
    end

    def fetch(auth_params = nil)
      auth_params ||= model.retrieval_keys.inject({}) do |h, k|
        return nil unless h[k] = self[k]
        h
      end
      model.find_for_authentication auth_params
    end
  end
end