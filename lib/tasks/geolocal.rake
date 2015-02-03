# require 'config/geolocal'

namespace :geolocal do
  desc "Downloads the most recent geocoding information"
  task :download do
    Geolocal
  end

  desc "Updates your geocoding statements to use new data."
  task :update => :download do
    puts "updated"
  end
end

desc "shorthand for running geolocal:update"
task geolocal: 'geolocal:update'
