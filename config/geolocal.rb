require 'geolocal'

Geolocal.configure do |config|
  config.countries = { us: 'US' }
end
