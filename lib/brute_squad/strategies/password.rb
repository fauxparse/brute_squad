module BruteSquad::Strategies
  class Password < Strategy
    configure :login_fields, :default => [ :email ]
    configure :allow_basic, :default => true
    
    def prepare(session)
      candidate = if allow_basic? && session.auth.provided? && session.auth.basic?
        session.candidate(login_fields.first => session.auth.username)
      else
        # for now, assume we can't just pick up authentication
        # parameters on any old request
      end
      
      if candidate
        # TODO: check password
        session.authenticate! candidate
      end
    end
  end
end