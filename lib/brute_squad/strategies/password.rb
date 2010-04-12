module BruteSquad::Strategies
  class Password < Strategy
    configure :login_fields, :default => [ :email ]
    configure :allow_basic, :default => true
    configure :allow_login_anywhere, :default => false
    configure :encryption, :default => BruteSquad::Encryption.default
    
    def prepare(session)
      candidate = if allow_basic? && session.auth.provided? && session.auth.basic?
        if candidate = session.candidate(login_fields.first => session.auth.username)
          authenticate(candidate, :password => session.auth.password) || session.deny!
        else
          false
        end
      elsif allow_login_anywhere?
        # for now, assume we can't just pick up authentication
        # parameters on any old request
      end
      
      if candidate
        session.authenticate! candidate
      end
    end
    
    def authenticate(candidate, params)
      if model.klass.respond_to?(:authenticate_with_password)
        model.klass.authenticate_with_password candidate, params
      else
        return false if candidate.nil? || !params[:password].present?
        
        password_tokens = [ params[:password] ]
        password_tokens << candidate.password_salt if candidate.respond_to? :password_salt
        if keymaker.match?(candidate.encrypted_password, *password_tokens)
          candidate
        else
          false
        end
      end
    end
    
  protected
    def keymaker
      BruteSquad::Encryption[encryption]
    end
  end
end