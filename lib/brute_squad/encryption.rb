module BruteSquad
  module Encryption
    class Encryptor
      def self.to_sym
        name.underscore.to_sym
      end
    end
    
    def self.default
      Sha512
    end
    
    def self.[](sym)
      case sym
      when Class then sym
      else
        const_get sym.to_s.classify.to_sym
      end
    end

    Dir[File.expand_path("encryption/*.rb", File.dirname(__FILE__))].each do |f|
      autoload File.basename(f, ".rb").classify.to_sym, f
    end
  end
end