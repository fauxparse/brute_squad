module BruteSquad
  class Model
    attr_reader   :name
    attr_accessor :singular, :class_name
    
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
    
    def singular(value = nil)
      @singular = value unless value.nil?
      @singular || name.to_s.singularize.to_sym
    end
    
    def class_name(value = nil)
      @class_name = value unless value.nil?
      @class_name || singular.to_s.classify
    end
    
  protected
    def klass
      @class_name.constantize
    end
  end
end