require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "hipchat"
    gem.summary = %Q{Ruby library to interact with HipChat}
    gem.description = %Q{Ruby library to interact with HipChat}
    gem.email = "gems@mojotech.com"
    gem.homepage = "http://github.com/mojotech/hipchat"
    gem.authors = ["MojoTech"]
    gem.add_dependency "httparty"
    gem.add_development_dependency "rspec", "~> 2.0"
    gem.add_development_dependency "rr", "~> 1.0"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

task :default => :spec

desc "Run specs"
RSpec::Core::RakeTask.new

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "hipchat #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
