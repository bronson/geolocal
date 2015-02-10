# If you're wondering why nothing's here, you probably wanted to require 'geolocal/configuration'
# Once you define a configuration and generate the geolocation code, this module will have contents.
module Geolocal
  require 'geolocal/railtie' if defined? Rails
end
