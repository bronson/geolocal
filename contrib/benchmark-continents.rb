# Shows timings for the generated continent selectors
# You must first run:
#
#     rake geolocal config=contrib/continents

require 'benchmark'
require_relative '../tmp/geolocal.rb'


N = 1_000_000

puts
puts "running #{N} lookups on each continent:"
puts

Benchmark.bm(15, 'africa/asia') do |x|
  spread = 2**32/N - 500     # tries to cover the IPv4 range reasonably well

  x.report('africa:')        { N.times { |i| Geolocal.in_africa?(i*spread, 2) } }
  x.report('antarcitca:')    { N.times { |i| Geolocal.in_antarctica?(i*spread, 2) } }
  x.report('asia:')          { N.times { |i| Geolocal.in_asia?(i*spread, 2) } }
  x.report('australia:')     { N.times { |i| Geolocal.in_australia?(i*spread, 2) } }
  x.report('europe:')        { N.times { |i| Geolocal.in_europe?(i*spread, 2) } }
  x.report('north_america:') { N.times { |i| Geolocal.in_north_america?(i*spread, 2) } }
  x.report('south_america:') { N.times { |i| Geolocal.in_south_america?(i*spread, 2) } }
end
