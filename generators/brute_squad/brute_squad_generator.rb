class BruteSquadGenerator < Rails::Generator::NamedBase
  def initialize(runtime_args, runtime_options = {})
    runtime_args << "user"  if runtime_args.empty?
    
    super
  end
    
  def manifest
    record do |m|
      m.template "brute_squad.rb", "config/initializers/brute_squad.rb"
    end
  end
end
