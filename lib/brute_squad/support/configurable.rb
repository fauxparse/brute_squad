module BruteSquad
  module Support
    module Configurable
      def self.included(base)
        base.extend ClassMethods
        base.instance_variable_set :"@configuration_options", {}
        class << base
          alias_method_chain :inherited, :configuration_options
        end
      end
      
      def set_defaults!
        self.class.configuration_options.each do |k, v|
          instance_variable_set :"@#{k}", default_value_for(k)
        end
      end

      def default_value_for(key)
        case (v = self.class.configuration_options[key])
        when Proc   then instance_eval(&v)
        when nil    then nil
        else v.dup
        end
      end
      
      module ClassMethods
        def configuration_options
          @configuration_options[self.name] ||= ActiveSupport::OrderedHash.new
        end
        
        def configure(*args, &block)
          if block_given?
            args << (Hash === args.last ? args.pop : {}).merge(:default => block)
            configure *args
          elsif Hash === args.first
            args.first.each_pair do |name, default|
              configure name, :default => default
            end
          elsif Hash === args.last
            options = args.pop
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
          else Proc === args.last
            args.push(:default => args.pop)
            configure *args
          end
        end

        def inherited_with_configuration_options(base) #:nodoc:
          inherited_without_configuration_options(base)
          @configuration_options[base.name] = configuration_options.dup
        end
      end
    end
  end
end