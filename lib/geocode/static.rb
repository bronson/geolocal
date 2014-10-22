require "geocode/static/version"
require "geocode/static/base"


module Geocode
  module Static
    def self.configuration
      {}
    end

    def self.configure
    end

    require 'geocode/static/railtie' if defined? Rails
  end
end
