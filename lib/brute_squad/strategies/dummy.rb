module BruteSquad::Strategies
  # Dummy strategy for testing **ONLY**.
  class Dummy < Strategy
    def prepare(session)
      session.redirect! "/products" unless session.env["PATH_INFO"] =~ /^\/products/
    end
  end
end