require 'geolocal/configuration'
require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.order = 'random'

  config.before :each do
    Geolocal.reset_configuration
    Geolocal.configure do |geoconf|
      geoconf.quiet = true
    end
  end
end
