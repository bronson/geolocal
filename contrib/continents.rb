# to generate selectors for each continent:
#
#     rake geolocal config=contrib/continents
#
# Now you can call Geolocal.in_africa?, in_antarcitca?, in_asia?, etc.


require 'geolocal/configuration'
require 'countries'


# creates in_x? methods for each continent: in_north_america?, in_europe?, etc.

Geolocal.configure do |config|
  continents = ISO3166::Country.all.group_by(&:continent)
  by_continent = continents.merge(continents) do |continent, countries|
    countries.map(&:alpha2)
  end

  config.countries = by_continent
  config.ipv6 = false
end
