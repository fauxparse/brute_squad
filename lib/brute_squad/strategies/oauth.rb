require "oauth"

module BruteSquad::Strategies
  # OAuth strategy for BruteSquad.
  # Requires the +oauth+ gem v0.3.6 or later (http://github.com/mojodna/oauth).
  class Oauth < Strategy
    configure :provider
    configure :consumer_key
    configure :consumer_secret

    def consumer
      @consumer ||= OAuth::Consumer.new(consumer_key, consumer_secret, :site => provider)
    end
    
    def authenticate(candidate, session, params)
      return false unless params[:oauth].present?

      request_token = consumer.get_request_token :oauth_callback => session.request.url
      session.set :oauth_request_token, request_token.token, true
      session.set :oauth_request_secret, request_token.token, true
      session.redirect! request_token.authorize_url, :message => "Redirecting you to #{provider} for authentication..."
    end
    
    def prepare(session)
      if session[:oauth_access_token] || session[:oauth_request_token]
        if access_token = get_access_token(session)
          candidate = model.klass.from_oauth_credentials access_token.token, access_token.secret
          session.authenticate! candidate, true if candidate
        end
      end
    end
    
    module ClassMethods
      def from_oauth_credentials(token, secret)
        find_or_initialize_by_oauth_token_and_oauth_secret(token, secret)
      end
      
      def oauth_consumer
        brute_squad.strategies[:oauth].consumer
      end
    end
    
    module InstanceMethods
      def oauth_access_token
        @oauth_access_token ||= OAuth::AccessToken.new(self.class.oauth_consumer, oauth_token, oauth_secret)
      end
    end
    
  protected
    def get_access_token(session)
      begin
        access_token = if session[:oauth_access_token]
          OAuth::AccessToken.new(consumer, session[:oauth_access_token], session[:oauth_access_secret])
        elsif session[:oauth_request_token] && session[:oauth_verifier]
          request_token = OAuth::RequestToken.new(consumer, session[:oauth_request_token], session[:oauth_request_secret])
          request_token.get_access_token :oauth_verifier => session[:oauth_verifier]
        else
          nil
        end
      
        if access_token
          session.set :oauth_access_token, access_token.token, true
          session.set :oauth_access_secret, access_token.secret, true
        end
        
        access_token
      rescue OAuth::Unauthorized => e
        nil
      end
    end
  end
end
