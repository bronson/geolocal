require 'csv'

class Geolocal::Provider::DB_IP < Geolocal::Provider::Base
  def download
    # go from here: http://db-ip.com/db/download/country
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
