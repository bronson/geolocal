require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

Dir.glob('lib/tasks/*.rake').each { |r| load r}

Geolocal.configure do |config|
  config.file = 'tmp/geolocal.rb' # 'lib/geolocal.rb' default would overwrite our source code
end

RSpec::Core::RakeTask.new(:spec)
task :default => ['spec']
task :test => ['spec']
