class BruteSquadGenerator < Rails::Generator::NamedBase
  attr_reader :model_name
  
  def initialize(runtime_args, runtime_options = {})
    runtime_args << "user"  if runtime_args.empty?
    super
  end
    
  def manifest
    record do |m|
      m.template "initializer.rb", "config/initializers/brute_squad_#{plural_name}.rb"
    end
  end
end
