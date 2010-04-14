module BruteSquad
  class Model
    include Support::Configurable
    
    attr_reader :name
    attr_reader :strategies

    configure(:singular)            { name.to_s.singularize.to_sym } 
    configure(:class_name)          { singular.to_s.classify }
    configure :session_secret
    configure :session_domain,      :default => nil
    configure :session_expiry,      :default => 2.weeks
    configure :keys,                :default => [ :id ]
    
    # Configure a new model for use with BruteSquad
    #
    # Accepts the following options:
    # :singular::    Singular name for the model
    # :class_name::  Class name of the model to use
    def initialize(model_name, options = {}, &block)
      @name = model_name.to_sym
      configure_with options, &block
      
      install_modules InstanceMethods, ClassMethods
      klass.class_eval <<-EOS
        def brute_squad
          BruteSquad[:#{model_name}]
        end
      EOS
    end
    
    def to_sym; name;      end
    def to_s;   name.to_s; end
    
    def configure_with(options, &block)
      @singular   = options[:singular] if options[:singular].present?
      @class_name = options[:class_name] if options[:class_name].present?
      instance_eval &block if block_given?
      self
    end
    
    def authenticate_with(*args, &block)
      options = args.extract_options!
      args.each do |sym|
        returning(strategies[sym.to_sym] ||= Strategies[sym].new(self, options)) do |strategy|
          strategy.instance_eval &block if block_given?
        end
      end
    end
    
    def prepare(session)
      strategies.each do |_, strategy|
        strategy.prepare session
      end
    end
    
    def authentication_for(instance)
      keys.inject({}) do |h, key|
        h[key] = instance.send key
        h
      end
    end
    
    def find_for_authentication(params)
      klass.find_for_authentication extract_finder_params(params)
    end
    
    def attempt(candidate, session, params)
      strategies.each_pair do |name, strategy|
        if result = strategy.authenticate(candidate, session, params)
          return strategy
        end
      end
      false
    end

    def klass #:nodoc:
      class_name.constantize
    end
    
    def persist
      false
    end
    
    module ClassMethods
      def find_for_authentication(params)
        first params
      end
    end
    
    module InstanceMethods
      
    end
    
    def install_modules(instance_methods = nil, class_methods = nil)
      # TODO: this fails if class caching is turned off
      klass.send :include, instance_methods if instance_methods
      klass.extend class_methods if class_methods
    end
    
    def strategies
      @strategies ||= ActiveSupport::OrderedHash.new
    end
    
  protected
    def extract_finder_params(params)
      params.inject({}) do |hash, (key, value)|
        hash[key] = params[key] if keys.include?(key)
        hash
      end
    end
  end
end