module BruteSquad
  module Rails
    def self.logger
      ::Rails.logger
    end
  end
end

require "brute_squad/rails/action_controller"

Rails.configuration.after_initialize do
  # we have to do this after we've configured Brute Squad
  ActionController::Base.send :include, BruteSquad::Rails::ActionControllerExtensions
end

Rails::Initializer.run do
  Rails.configuration.middleware.use BruteSquad::Middleware
end
