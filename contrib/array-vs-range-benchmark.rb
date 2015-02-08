require 'benchmark'

# This shows that Ranges are about twice as fast as 2-element Arrays
# Unless the range is (1.to_i..2.to_i), which is identical to Arrays

N = 10_000_000

$a = []
$r = []

def array
  $a << [1,2]
end

def range
  $r << (1..2)
end

Benchmark.bm(15, 'array/range') do |x|
  array_report = x.report('array:') { N.times { array } }
  range_report = x.report('range:') { N.times { range } }
  [array_report / range_report]
end
