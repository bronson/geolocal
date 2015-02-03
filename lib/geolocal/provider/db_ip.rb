require 'csv'
require 'open-uri'
require 'nokogiri'

class Geolocal::Provider::DB_IP < Geolocal::Provider::Base
  START_URL = 'https://db-ip.com/db/download/country'

  def fetch(url)
    open(url, redirect: true) do |file|
      yield file
    end
  end

  def download
    href = nil
    fetch(START_URL) do |io|
      page = Nokogiri::HTML(io)
      href = page.css('a.btn-primary').attr('href').to_s
    end

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
