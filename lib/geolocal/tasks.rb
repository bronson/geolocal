require 'geolocal/configuration'

namespace :geolocal do
  def configured_provider
    # we use this file by default
    config='config/geolocal'

    # but you can specify the config file on the command line:
    #     `rake geolocal config=contrib/continents`
    config=ENV['config'] if ENV['config']
    puts "loading geolocal configuration from #{config}"
    require './' + config

    Geolocal.configuration.load_provider.new
  end

  desc "Downloads the most recent geocoding information"
  task :download do
    configured_provider.download
  end

  desc "Updates your geocoding statements to use new data."
  task :update => :download do
    configured_provider.update
  end
end

desc "shorthand for running geolocal:update"
task geolocal: 'geolocal:update'
