require "geocode/static/version"
require "geocode/static/provider"


module Geocode
  module Static
    require 'geocode/static/railtie' if defined? Rails
  end
end
