require 'rubygems'
require 'rake'
require 'spec/rake/spectask'

desc 'Default: run specs.'
task :default => :spec

desc 'Run the specs'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ['--colour --format progress --loadby mtime --reverse']
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.rcov = true
  t.rcov_opts = ['--text-report --rails --exclude "spec/*"']
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

begin
  require 'hanna/rdoctask'
rescue
  require 'rake/rdoctask'
end

desc 'Generate RDoc documentation.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_files.include('README.rdoc').
    include('lib/**/*.rb')

  rdoc.main = "README.rdoc" # page to start on
  rdoc.title = "Brute Squad"

  rdoc.rdoc_dir = 'doc' # rdoc output folder
  rdoc.options << '--webcvs=http://github.com/fauxparse/credentials/'
end