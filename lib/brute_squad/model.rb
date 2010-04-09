module BruteSquad
  class Model
    include Support::Configurable
    
    attr_reader :name
    attr_reader :strategies

    configure(:singular)   { name.to_s.singularize.to_sym } 
    configure(:class_name) { singular.to_s.classify }
    
    # Configure a new model for use with BruteSquad
    #
    # Accepts the following options:
    # :singular::    Singular name for the model
    # :class_name::  Class name of the model to use
    def initialize(model_name, options = {})
      @name = model_name.to_sym
      configure_with options
    end
    
    def to_sym; name;      end
    def to_s;   name.to_s; end
    
    def configure_with(options)
      @singular   = options[:singular] if options[:singular].present?
      @class_name = options[:class_name] if options[:class_name].present?
      self
    end
    
    def authenticate_with(*args, &block)
      options = args.extract_options!
      args.each do |sym|
        strategies[sym.to_sym] = returning Strategies[sym].new(self, options) do |strategy|
          strategy.instance_eval &block if block_given?
        end
      end
    end
    
    def prepare_request(request)
      strategies.each do |_, strategy|
        strategy.prepare_request request
      end
    end
    
  protected
    def klass #:nodoc:
      @class_name.constantize
    end
    
    def strategies
      @strategies ||= ActiveSupport::OrderedHash.new
    end
  end
end