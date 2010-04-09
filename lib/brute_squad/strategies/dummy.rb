module BruteSquad::Strategies
  # Dummy strategy for testing **ONLY**.
  class Dummy < Strategy
    def prepare_request(request)
      request.redirect! "/products" unless request.env["PATH_INFO"] =~ /^\/products/
    end
  end
end