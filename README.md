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
create `lib/geolocal.rb`.

```ruby
Geolocal.in_us?(request.remote_ip)
Geolocal.in_central_america?(IPAddr.new('200.16.66.0'))
```

You can pass a string (`in_us? "10.1.2.3"`),
[IPAddr](http://www.ruby-doc.org/stdlib-2.2.0/libdoc/ipaddr/rdoc/IPAddr.html) object,
or integer/family combo (`in_us? 167838211, Socket::AF_INET`).

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


## Alternatives

The [Geocoder gem](https://github.com/alexreisner/geocoder) offers
[local database services](https://github.com/alexreisner/geocoder#ip-address-local-database-services).
Geolocal is simpler, faster, and production ready, but the Geocoder gem offers more options and more providers.
Geolocal also doesn't add any dependencies to your deploy, potentially making it easier to get working with oddball
environments like Heroku.


## TODO

- [ ] performance information?  benchmarks.  space saving by going ipv4-only?
- [ ] include a Rails generator for the config file?
- [ ] write a command that takes the config on the command line and writes the result to stdout?
- [ ] Add support for cities
- [ ] replace Nokogiri dependency with a single regex?  Shame to force that dependency on all clients.
- [ ] other sources for this data? [MainFacts](http://mainfacts.com/ip-address-space-addresses), [NirSoft](http://www.nirsoft.net/countryip/)
- [ ] Add support for for-pay features like lat/lon and timezones?


## Contributing

To make this gem less imperfect, please submit your issues and patches on
[GitHub](https://github.com/bronson/geolocal/).
