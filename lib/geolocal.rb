require 'geolocal/version'
require 'geolocal/configuration'


module Geolocal
  require 'geolocal/railtie' if defined? Rails

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.reset_configuration
    @configuration = nil
  end

  module Provider
  end
end
