module BruteSquad
  class Model
    include Support::Configurable
    
    attr_reader :name

    configure(:singular)   { name.to_s.singularize.to_sym } 
    configure(:class_name) { singular.to_s.classify }
    
    # Configure a new model for use with BruteSquad
    #
    # Accepts the following options:
    # :singular::    Singular name for the model
    # :class_name::  Class name of the model to use
    def initialize(model_name, options = {})
      @name       = model_name
      @singular   = options[:singular] if options[:singular].present?
      @class_name = options[:class_name] if options[:class_name].present?
    end
    
    def authenticate_with(*args)
      
    end

  protected
    def klass #:nodoc:
      @class_name.constantize
    end
  end
end