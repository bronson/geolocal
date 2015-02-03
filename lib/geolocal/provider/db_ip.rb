require 'csv'
require 'net/http'
require 'nokogiri'


class Geolocal::Provider::DB_IP < Geolocal::Provider::Base
  START_URL = 'https://db-ip.com/db/download/country'

  def fetch(url)
    open(url, redirect: true) do |file|
      yield file
    end
  end

  def download
    page = Net::HTTP.get(URI START_URL)
    doc = Nokogiri::HTML(page)
    href = doc.css('a.btn-primary').attr('href').to_s

    puts "downloading #{href}"
  end

  def update
    # why on earth doesn't CSV.new(STDIN).each work?  Slurping sux.
    CSV.new(STDIN.read, headers: false).each do |row|
      ranges.each do |name, countries|
        if countries.include?(row[2])
          yield IPAddr.new(row[0]), IPAddr.new(row[1])
        end
      end
    end

    results
  end
end
