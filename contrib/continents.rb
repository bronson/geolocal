require 'geolocal'
require 'countries'


# creates in_x? methods for each continent: in_north_america?, in_europe?, etc.

Geolocal.configure do |config|
  all_countries = Country.all.map { |c| Country[c[1]] }

  # { 'antarctica' => ['AQ', 'BV', ...], 'australia' => ['AS', 'AU', ...], ... }
  by_continent = all_countries.reduce({}) { |hash,country|
    continent = country.continent.downcase;
    hash[continent] ||= [];
    hash[continent] << country.alpha2;
    hash
  }

  config.countries = by_continent
  config.ipv6 = false
end
