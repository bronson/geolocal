module Geolocal
  class Configuration
    OPTIONS = [ :provider, :module, :file, :tmpdir, :ipv4, :ipv6, :quiet, :countries ]
    attr_accessor(*OPTIONS)

    def initialize
      # configuration defaults
      @provider = 'Geolocal::Provider::DB_IP'
      @module = 'Geolocal'
      @file = nil       # default is computed
      @tmpdir = 'tmp/geolocal'
      @ipv4 = true
      @ipv6 = true
      @quiet = false
      @countries = {}
    end

    # if not set, defaults to lib/module-name
    def file
      @file || "lib/#{module_file @module}.rb"
    end

    def require_provider_file
      begin
        # normal ruby/gem load path
        Kernel.require module_file(@provider)
      rescue LoadError
        # used when running source code locally
        Kernel.require "./lib/#{module_file(@provider)}.rb"
      end
    end

    def load_provider
      require_provider_file
      @provider.split('::').reduce(Module, :const_get)
    end

    def to_hash
      # returned keys will always be symbols
      OPTIONS.reduce({}) { |a,v| a.merge! v => self.send(v) }
    end

    def module_file modname
      modname.gsub('::', '/').gsub(/([a-z])([A-Z])/, '\1_\2').downcase
    end
  end


  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.reset_configuration
    @configuration = nil
  end
end
