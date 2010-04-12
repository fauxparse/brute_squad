$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
$:.unshift File.expand_path(File.join(File.dirname(__FILE__)))
require "brute_squad"

require "rubygems"
require "rack"

Dir[File.join(File.dirname(__FILE__), "helpers", "**/*.rb")].each do |f|
  require f
end

include BruteSquad::Spec::Helpers

Spec::Runner.configure do |config|
  # config.include(BruteSquad::Spec::Helpers)
  
  config.before :each do
    BruteSquad.models.clear
    TestUser.instances.clear
  end
end
