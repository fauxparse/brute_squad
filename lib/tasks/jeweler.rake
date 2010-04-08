begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name           = "brute_squad"
    gem.summary        = "No-bullshit authentication for Rails"
    gem.description    = "Sick of authentication frameworks with all the sauces? Me too."
    gem.email          = "fauxparse@gmail.com"
    gem.homepage       = "http://github.com/fauxparse/brute_squad"
    gem.authors        = ["Matt Powell"]
    gem.add_dependency   "activesupport", ">=2.3.5"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
