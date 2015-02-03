class Configuration
  attr_accessor :provider, :module, :file, :tmpdir, :expires, :ipv6, :countries

  def initialize
    # configuration defaults
    @provider = 'Geolocal::Provider::DB_IP'
    @module = 'Geolocal'
    @file = nil  # default is computed
    @tmpdir = 'tmp/geolocal'
    @expires = Time.now + 86400*30
    @ipv6 = true
    @countries = {}
  end

  # if not set, defaults to lib/module-name
  def file
    @file || self.class.module_file(@module)
  end

  def provider
    @provider.split('::').reduce(Module, :const_get)
  end

  def self.module_file modname
    "lib/#{modname.gsub('::', '/').gsub(/([a-z])([A-Z])/, '\1_\2').downcase}.rb"
  end
end
