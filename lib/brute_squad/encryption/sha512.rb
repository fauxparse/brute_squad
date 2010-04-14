module BruteSquad
  module Encryption
    class Sha512 < Encryptor
      class << self
        attr_accessor :join_token
        
        def stretches
          @stretches ||= 10
        end
        attr_writer :stretches
        
        def encrypt(*tokens)
          digest = tokens.flatten.join(join_token)
          stretches.times { digest = Digest::SHA512.hexdigest(digest) }
          digest
        end
      end
    end
  end
end