class Configuration
  OPTIONS = [ :provider, :module, :file, :tmpdir, :expires, :ipv6, :countries ]
  attr_accessor(*OPTIONS)

  def initialize
    # configuration defaults
    @provider = 'Geolocal::Provider::DB_IP'
    @module = 'Geolocal'
    @file = nil  # default is computed
    @tmpdir = 'tmp/geolocal'
    @expires = 86400*30
    @ipv6 = true
    @countries = {}
  end

  # if not set, defaults to lib/module-name
  def file
    @file || self.class.module_file(@module)
  end

  def provider
    require './' + self.class.module_file(@provider)
    @provider.split('::').reduce(Module, :const_get)
  end

  def to_hash
    # returned keys will always be symbols
    OPTIONS.reduce({}) { |a,v| a.merge! v => instance_variable_get('@'+v.to_s) }
  end

  def self.module_file modname
    "lib/#{modname.gsub('::', '/').gsub(/([a-z])([A-Z])/, '\1_\2').downcase}.rb"
  end
end
