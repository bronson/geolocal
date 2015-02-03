# Geolocal

Allows IP addresses to geocoded with a single Ruby if statement.
No network access, no context switches, no delay.  Just one low-calorie local lookup.


## Installation

The usual method, add this line to your Gemfile:

```ruby
gem 'geolocal'
```


## Usage

First create a config file that describes the ranges you're interested in.
Here's an example:

```ruby
Geolocal.configure do
  config.countries = {
    us: 'US',
    central_america: %w[ BZ CR SV GT HN NI PA ]
  }
end
```

Now run `rake geolocal:update`.  It will download the geocoding data
from the default provider (see the [providers](#providers) section) and
create `lib/geocode.rb`.

```ruby
Geocode.in_us?(request.remote_ip)
Geocode.in_central_america?(IPAddr.new('200.16.66.0'))
```


## Config

Here are the most common config keys.  See the docs for the provider
you're using for more.

* **provider**: Where to download the geocoding data.  Default: DB_IP.
* **module**: The name of the module to receive the `in_*` methods.  Default: 'Geolocal'.
* **file**: Path to the file to contain the generated code.  Default: `lib/#{module}.rb`.
* **tmpdir**: the directory to contain intermediate files.  They will require tens of megabytes
  for countries, hundreds for cities).  Default: `./tmp/geolocal`
* **expires**: the amount of time to consider downloaded data valid.  Default: 1.month
* **countries**: the ISO-codes of the countries to include in the lookup.
* **ipv6**: whether the ranges should support ipv6 addresses.


## Examples

This uses the [Countries](https://github.com/hexorx/countries) gem
to discover if an address is in the European Union:

```ruby
require 'countries'

eu_codes = Country.find_all_by_eu_member(true).map(&:first)

Geolocal.configure do |config|
  config.countries = { us: 'US', eu: eu_codes }
end
```

Now you can call `Geolocal.in_eu?(ip)`.  If the European Union ever changes,
run `bundle update countries` and then `rake geolocal`.

## Providers

This gem currently only supoports the [DB-IP](https://db-ip.com/about/) database.
There are lots of other databases available and this gem is organized to support them.
Patches welcome.


## TODO

- [ ] performance information?  benchmarks.  space saving by going ipv4-only?
- [ ] include a Rails generator for the config file?
- [ ] write a command that takes the config on the command line and writes the result to stdout?
- [ ] Add support for cities
- [ ] other sources for this data? [MainFacts](http://mainfacts.com/ip-address-space-addresses), [NirSoft](http://www.nirsoft.net/countryip/)
- [ ] Add support for for-pay features like lat/lon and timezones?
- [ ] Remove Nokogiri dependency?  It's only needed when updating ranges.  It's a shame to force an app to include it when we hardly even need it ourselves.


## Contributing

To make this gem less imperfect, please submit your issues and patches on
[GitHub](https://github.com/bronson/geolocal/).
