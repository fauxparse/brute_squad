module BruteSquad
  module Strategies
    class Strategy
      include Support::Configurable

      def initialize(options = {})

      end
    end

    def self.strategies
      @strategies ||= {}
    end
    
    def self.register(strategy, path)
      autoload(strategies[strategy.to_sym] = strategy.to_s.classify.to_sym, path)
    end
    
    def self.[](sym)
      const_get(strategies[sym.to_sym])
    end
    
    Dir[File.expand_path("strategies/*.rb", File.dirname(__FILE__))].each do |f|
      register File.basename(f, ".rb").to_sym, f
    end
  end
end
