require 'geolocal/configuration'

Geolocal.configure do |config|
  # This example creates a Geolocal.in_us?(addr) command:
  config.countries = { us: 'US' }

  # This is where the output goes.  You should commit it to your project.
  # config.module = 'Geolocal'
  # config.file = 'lib/geolocal.rb'

  # If your host is IPv4 only, you can save space by omitting IPv6 data and vice versa.
  # config.ipv6 = true
  # config.ipv4 = true

  # Download and process the geocoding data in this directory.  Don't commit it.
  # config.tmpdir = './tmp/geolocal'
end
