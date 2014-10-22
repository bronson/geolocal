# Geocode::Static

Allows IP address to geocoded with a single Ruby if statement.
Checking whether an IP address is in a country or a continent is as easy
as calling `addr.in_eu?`.  No network access, no context switches, no delay.


## Installation

The usual method, add this line to your Gemfile:

```ruby
gem 'geocode-static'
```


## Usage

First create a config file that describes the ranges you're interested in.
Here's an example:

```ruby
Geocode::Static.configure do
  config.countries = { us: 'US' }
end
```

Now run `rake geocode:update`.  It will download the geocoding data
from the default provider (currently [db-ip](https://db-ip.com/)) and
create `lib/Geocode.rb`.

```ruby
Geocode.in_us?(request.remote_ip)
```


## Config

Here are the most common config keys.  See the docs for the provider
you're using for more.

* **provider**: Where to download the geocoding data.  Default: DB_IP.
* **module**: The name of the module to receive the `in_*` methods.  Default: 'Geocode'.
* **file**: Path to the file to contain the generated module.  Default: `lib/#{module}.rb`.
* **tmpdir**: the directory to contain intermediate files.  Default: `./tmp/geocode-static`
* **expires**: the amount of time to consider downloaded data valid.  Default: 1.month
* **countries**: the ISO-code of the countries to include in the lookup.


## Examples

```ruby
config.countries = { central_america: %w[ BZ CR SV GT HN NI PA ] }

Geocode.in_central_america?(IPAddr.new('200.16.66.0'))
```

Here's a more complex example using the [Countries](https://github.com/hexorx/countries) gem
to discover if an address is in the European Union:

```ruby
require 'countries'

eu = Country.find_all_by_eu_member(true).map(&:first)

Geocode::Static.configure do
  config.countries = { us: 'US', eu: eu }
end
```


## TODO

- link DB_IP in config section to online documentation.
- write a command that takes the config on the command line and writes the result to stdout?
- performance information?
- is there a better name?  Geocode::Quick?  GeoQuick?  GeoRanges?
- include a Rails generator for the config file?
- other sources for this data? [MainFacts](http://mainfacts.com/ip-address-space-addresses), [NirSoft](http://www.nirsoft.net/countryip/)


## Contributing

To make this gem less imperfect, submit your issues and patches on GitHub.
