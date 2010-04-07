require 'rubygems'
require 'rake'
require 'spec/rake/spectask'

desc 'Default: run specs.'
task :default => :spec

desc 'Run the specs'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ['--colour --format progress --loadby mtime --reverse']
  t.spec_files = FileList['spec/**/*_spec.rb']
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "brute_squad"
    gemspec.summary = "No-bullshit authentication for Rails"
    gemspec.description = "Sick of authentication frameworks with all the sauces? Me too."
    gemspec.email = "fauxparse@gmail.com"
    gemspec.homepage = "http://github.com/fauxparse/brute_squad"
    gemspec.authors = ["Matt Powell"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
