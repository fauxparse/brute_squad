Rails::Initializer.run do
  Rails.configuration.middleware.use BruteSquad::Enforcer
end
