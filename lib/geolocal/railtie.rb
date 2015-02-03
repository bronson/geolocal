require 'geolocal'
require 'rails'

module Geolocal
  class Railtie < Rails::Railtie
    railtie_name :geolocal

    rake_tasks do
      load "tasks/geolocal.rake"
    end
  end
end
