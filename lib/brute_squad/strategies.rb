module BruteSquad
  module Strategies
    class Strategy
      include Support::Configurable

      attr_reader :model
      
      def initialize(model, options = {})
        @model = model
        @options = options
        @model.install_modules(
          self.class.helper_module(:InstanceMethods),
          self.class.helper_module(:ClassMethods)
        )
      end
      
      def prepare_request(request)
        
      end

    protected
      def self.helper_module(name)
        begin
          const_get name
        rescue NameError
          nil
        end
      end
    end

    def self.strategies
      @strategies ||= {}
    end
    
    def self.register(strategy, path = nil)
      strategies[strategy.to_sym] = strategy.to_s.classify.to_sym
      autoload(strategies[strategy.to_sym], path) if path
    end
    
    def self.[](sym)
      const_get(strategies[sym.to_sym])
    end
    
    Dir[File.expand_path("strategies/*.rb", File.dirname(__FILE__))].each do |f|
      register File.basename(f, ".rb").to_sym, f
    end
  end
end
