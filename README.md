# Geolocal

[![Build Status](https://travis-ci.org/bronson/geolocal.svg?branch=master)](https://travis-ci.org/bronson/geolocal)
[![Gem Version](https://badge.fury.io/rb/geolocal.svg)](http://badge.fury.io/rb/geolocal)


Geocode IP addresses with a single Ruby if statement.
No network access, no context switches, no delay,
just one low-calorie lookup.

```ruby
Geolocal.in_spain?(request.remote_ip)
```

500,000 individual lookups per second is fairly typical performance.


## Installation

Add this line to your Gemfile:

```ruby
gem 'geolocal'
```

And this line to your Rakefile:

```ruby
require 'geolocal/tasks'
```


## Usage

Geolocal creates routines that return true or false depending on whether a particular IP address is within an area.
A config file describes the areas you're interested in.

If you're using Rails, run `rails generate geolocal` to create the config file.
Otherwise, crib from [config/geolocal.rb](https://github.com/bronson/geolocal/tree/master/config/geolocal.rb).

Here's an example that creates three queries: `in_us?`, `in_spain?`,
and `in_central_america?`:

```ruby
require 'geolocal/configuration'

Geolocal.configure do |config|
  config.countries = {
    us: 'US',
    spain: 'ES',
    central_america: %w[ BZ CR SV GT HN NI PA ]
  }
end
```

Now run `rake geolocal:update`.  Geolocal downloads the geocoding data
from the default provider (see the [providers](#providers) section) and
generates the methods:

```ruby
require 'geolocal'

Geolocal.in_us?(request.remote_ip)
Geolocal.in_spain?('2a05:af06::')  # optional IPv6 support
Geolocal.in_central_america?('200.16.66.0')
```

#### The in\_*area*? method

Call this routine to discover whether an address is inside or outside the given area.
You can pass:

* a string: `Geolocal.in_us?("10.1.2.3")`
* an [IPAddr](http://www.ruby-doc.org/stdlib-2.2.0/libdoc/ipaddr/rdoc/IPAddr.html) object:
  `Geolocal.in_eu?(IPAddr.new('2.16.54.0'))`
* an integer/family combo: `Geolocal.in_asia?(167838211, Socket::AF_INET)`

It returns true if the IP address is in the area, false if not.

It works by generating a static array of ranges.  `in_area?` binary
searches the appropriate array to determine whether the desired
address is contained or not.


## Config

Here are the supported configuration options:

* **provider**: Where to download the geocoding data.  See [Providers](#providers) below.  Default: DB_IP.
* **module**: The name of the module to receive the `in_*` methods.  Default: 'Geolocal'.
* **file**: Path to the file to contain the generated code.  Default: `lib/#{module}.rb`.
* **tmpdir**: the directory to contain intermediate files.  They will require tens of megabytes
  for countries, hundreds for cities).  Default: `./tmp/geolocal`
* **countries**: the ISO-codes of the countries to include in the lookup.
* **ipv6**: whether the ranges should support ipv6 addresses.
* **ipv4**: whether the ranges should support ipv4 addresses.

If you don't compile in an address family, but you pass Geolocal an address in that
family (say, you omit ipv6 but call `Geolocal.in_us?('::1')`), then Geolocal will
return false.  It will always assume the address is outside your ranges.


## Providers

This gem currently only supoports the [DB-IP](https://db-ip.com/about/) Countries database.
There are lots of other databases available and this gem is organized to support them one day.
Patches welcome.


## Examples

There are some examples in the [contrib](https://github.com/bronson/geolocal/tree/master/contrib) directory.
Run them like this:

```sh
git clone https://github.com/bronson/geolocal
cd geolocal
rake geolocal config=contrib/continents
```

Now look at the `tmp/geolocal.rb` file.  Beware, it's big!

Here's an example of using it from a command.  The `-Itmp` argument ensures `require` will
load `tmp/geolocal.rb`, then we just look up the IP address `8.8.8.8`.

```bash
ruby -Itmp -e 'require "geolocal"; puts Geolocal.in_north_america?("8.8.8.8") ? "yes!" : "nope"'
```


#### in_eu?

It's easy to use the [Countries](https://github.com/hexorx/countries) gem
to create a `Geolocal.in_eu?(ip_addr)` method:

```ruby
require 'countries'

eu_codes = ISO3166::Country.find_all_by_eu_member(true).map(&:first)

Geolocal.configure do |config|
  config.countries = { us: 'US', eu: eu_codes }
end
```

Now you can use it in your app: `cookie_warning if Geolocal.in_eu?(request.remote_ip)`

If European Union membership ever changes, just run `bundle update countries`
and `rake geolocal` to bring your app back up to date.


## Performance

It depends on how large an area you're looking up.  `Geolocal.in_antarctica?` will
take less than half the time of `Geolocal.in_asia?`.  Generally, you can
expect to do better than a million lookups every two seconds.

To see for yourself, run the continents benchmark:

```sh
rake geolocal config=contrib/continents
ruby contrib/benchmark-continents.rb
```


## Alternatives

The [Geocoder gem](https://github.com/alexreisner/geocoder) also offers
[local database services](https://github.com/alexreisner/geocoder#ip-address-local-database-services).
It offers more options and more providers than Geolocal, but it's a little more complex and not as fast.
Geolocal also doesn't add any dependencies to your deploy, potentially making it easier to get it working
with oddball environments like Heroku.


## Roadmap

Geolocal is running on multiple production sites.  It has proven itself to be fast and stable.
These features would be nice but may never be implemented.  Just depends on demand.

* Detect nesting?  A config file with in_eu? and in_france? would generate a fair amount of redundant code.
* Add support for cities
* other sources for this data? [MainFacts](http://mainfacts.com/ip-address-space-addresses), [NirSoft](http://www.nirsoft.net/countryip/)
  Also maybe allow providers to accept their own options?


## License

The code is MIT.  Downloaded data is copyrighted by the provider you downloaded it from.


## Contributing

To make this gem less imperfect, please submit your issues and patches on
[GitHub](https://github.com/bronson/geolocal/).
