# Geolocal

Allows IP addresses to geocoded with a single Ruby if statement.
No network access, no context switches, no delay.  Just one low-calorie local lookup.


## Installation

Add this line to your Gemfile:

```ruby
gem 'geolocal'
```


## Usage

If you're using Rails, run `rails generate geolocal` to create the configuration file.
Otherwise, crib from [config/geolocal.rb](https://github.com/bronson/geolocal/tree/master/config/geolocal.rb).

The config file describes the ranges you're interested in.
Here's an example:

```ruby
Geolocal.configure do
  config.countries = {
    us: 'US',
    central_america: %w[ BZ CR SV GT HN NI PA ]
  }
end
```

Now run `rake geolocal:update`.  Geolocal downloads the geocoding data
from the default provider (see the [providers](#providers) section) and
creates the desired methods:

```ruby
Geolocal.in_us?(request.remote_ip)
Geolocal.in_central_america?(200.16.66.0)
```

#### The in\_*area*? method

`rake geolocal:update` generates these methods.  You can pass:
* a string: `Geolocal.in_us?("10.1.2.3")`
* an [IPAddr](http://www.ruby-doc.org/stdlib-2.2.0/libdoc/ipaddr/rdoc/IPAddr.html) object:
  `Geolocal.in_eu?(IPAddr.new('2.16.54.0'))`
* an integer/family combo: `Geolocal.in_asia?(167838211, Socket::AF_INET)`

It returns true if the IP address is in the area, false if not.

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

There are some examples in the [contrib](https://github.com/bronson/geolocal/tree/master/contrib) directory.
Run them like this:

```sh
git clone https://github.com/bronson/geolocal
cd geolocal
rake geolocal config=contrib/continents.rb
```


#### in_eu?

It's easy to use the [Countries](https://github.com/hexorx/countries) gem
to create a `Geolocal.in_eu?(ip_addr)` method:

```ruby
require 'countries'

eu_codes = Country.find_all_by_eu_member(true).map(&:first)

Geolocal.configure do |config|
  config.countries = { us: 'US', eu: eu_codes }
end
```

If European Union membership ever changes, just run `bundle update countries`
and `rake geolocal` to bring your app back up to date.



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

- [ ] performance information / benchmarks?
- [ ] Add support for cities
- [ ] other sources for this data? [MainFacts](http://mainfacts.com/ip-address-space-addresses), [NirSoft](http://www.nirsoft.net/countryip/)
      Also maybe allow providers to accept their own options?
- [ ] Add support for for-pay features like lat/lon and timezones?


## Contributing

To make this gem less imperfect, please submit your issues and patches on
[GitHub](https://github.com/bronson/geolocal/).
