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

You can pass:
* a string: `Geolocal.in_us?("10.1.2.3")`
* an [IPAddr](http://www.ruby-doc.org/stdlib-2.2.0/libdoc/ipaddr/rdoc/IPAddr.html) object:
  `Geolocal.in_eu?(IPAddr.new('2.16.54.0'))`
* an integer/family combo: `Geolocal.in_us?(167838211, Socket::AF_INET)`

## Config

Here are the supported configuration options:

* **provider**: Where to download the geocoding data.  Default: DB_IP.
* **module**: The name of the module to receive the `in_*` methods.  Default: 'Geolocal'.
* **file**: Path to the file to contain the generated code.  Default: `lib/#{module}.rb`.
* **tmpdir**: the directory to contain intermediate files.  They will require tens of megabytes
  for countries, hundreds for cities).  Default: `./tmp/geolocal`
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

Now you can call `Geolocal.in_eu?(ip)`.  If the European Union membership ever changes,
run `bundle update countries` and then `rake geolocal` to bring your app up to date.

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

- [ ] include a Rails generator for the config file?
- [ ] performance information?  benchmarks.  space saving by going ipv4-only?
- [ ] Add support for cities
- [ ] other sources for this data? [MainFacts](http://mainfacts.com/ip-address-space-addresses), [NirSoft](http://www.nirsoft.net/countryip/)
      Also maybe allow providers to accept their own options?
- [ ] Add support for for-pay features like lat/lon and timezones?


## Contributing

To make this gem less imperfect, please submit your issues and patches on
[GitHub](https://github.com/bronson/geolocal/).
