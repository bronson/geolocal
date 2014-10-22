require 'geocode/static'
require 'rails'

module Geocode
  module Static
    class Railtie < Rails::Railtie
      railtie_name :geocode_static

      rake_tasks do
        load "tasks/geocode_static.rake"
      end
    end
  end
end
