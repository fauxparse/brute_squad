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
  end
end
