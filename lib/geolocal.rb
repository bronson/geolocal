require 'geolocal/version'
require 'geolocal/configuration'
require 'geolocal/provider/base'


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

  def self.provider
    @provider ||= configuration.provider.new
  end

  def self.download
    provider.download
  end

  def self.update
    provider.update
  end
end
