module BruteSquad
  module Support
    module Configurable
      def self.included(base)
        base.extend ClassMethods
        unless base.configuration_options.present?
          base.write_inheritable_attribute :configuration_options, ActiveSupport::OrderedHash.new
        end
      end
      
      def set_defaults!
        self.class.configuration_options.each do |k, v|
          instance_variable_set :"@#{k}", default_value_for(k)
        end
      end

      def default_value_for(key)
        case (v = self.class.configuration_options[key])
        when Proc then instance_eval(&v)
        when nil then nil
        else v.duplicable? ? v.dup : v
        end
      end
      
      module ClassMethods
        def configuration_options
          read_inheritable_attribute :configuration_options
        end
        
        def configure(*args, &block)
          if block_given?
            args << (args.extract_options!).merge(:default => block)
            configure *args
          elsif Hash === args.first
            args.first.each_pair do |name, default|
              configure name, :default => default
            end
          else
            options = args.extract_options!
            args.each do |name|
              configuration_options[name.to_sym] = options[:default]
              class_eval <<-EOS
                def #{name}(*value)
                  @#{name} = value.first if value.any?
                  @#{name}.nil? ? default_value_for(:#{name}) : @#{name}
                end
                alias_method :#{name}=, :#{name}
              EOS
            end
          end
        end
      end
    end
  end
end