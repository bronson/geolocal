require "geocode/static/version"
require "geocode/static/base"


module Geocode
  module Static
    require 'geocode/static/railtie' if defined? Rails


    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.configure
      yield(configuration)
    end

    def self.reset_configuration
      @configuration = nil
    end

    class Configuration
      attr_accessor :provider, :module, :file, :tmpdir, :expires, :countries

      def initialize
        @provider = 'Geocode::Static::DB_IP'
        @module = 'Geocode'
        @tmpdir = 'tmp/geocode-static'
        @expires = Time.now + 86400*30
        @countries = {}
      end

      # if not set, defaults to lib/module-name
      def file
        @file || "lib/#{@module.gsub('::', '/').gsub(/(.)([A-Z])/, '\1_\2').downcase}.rb"
      end
    end
  end
end
