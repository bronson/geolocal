class Configuration
  attr_accessor :provider, :module, :file, :tmpdir, :expires, :ipv6, :countries

  def initialize
    # configuration defaults
    @provider = 'Geolocal::Provider::DB_IP'
    @module = 'Geolocal'
    @tmpdir = 'tmp/geolocal'
    @expires = Time.now + 86400*30
    @ipv6 = true
    @countries = {}
  end

  # if not set, defaults to lib/module-name
  def file
    @file || "lib/#{@module.gsub('::', '/').gsub(/([a-zA-Z])([A-Z])/, '\1_\2').downcase}.rb"
  end
end
