require "rails/generators"

class BruteSquadGenerator < Rails::Generators::NamedBase
  # make the name argument default to "user"
  arguments.first.instance_eval do
    @default = "user"
    @required = false
  end

  def initialize(args, *options)
    super
  end
  
  def create_initializer
    template "initializer.rb", "config/initializers/brute_squad_#{plural_name}.rb"
  end
  
  def self.source_root
    File.join(File.dirname(__FILE__), 'templates')
  end
end