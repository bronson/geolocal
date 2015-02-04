require 'csv'
require 'net/http'
require 'fileutils'
require 'zlib'

require 'nokogiri'


class Geolocal::Provider::DB_IP < Geolocal::Provider::Base
  START_URL = 'https://db-ip.com/db/download/country'

  # TODO: refactor progress and download code into a mixin?

  def status size, length
    @current_byte ||= 0
    @previous_print ||= 0
    @current_byte += size

    if length
      pct = @current_byte * 100 / length
      pct = (pct / 5) * 5

      if pct != @previous_print
        @previous_print = pct
        print pct.to_s + '% '
        $stdout.flush
      end
    else
      # server didn't supply a length, display running byte count?
    end
  end

  def puts *args
    Kernel.puts(*args)
  end

  def print *args
    Kernel.print(*args)
    $stdout.flush
  end

  def csv_file
    "#{config[:tmpdir]}/dbip-country.csv.gz"
  end

  def download_files
    page = Net::HTTP.get(URI START_URL)
    doc = Nokogiri::HTML(page)
    href = URI.parse doc.css('a.btn-primary').attr('href').to_s

    # stream result because it's large
    FileUtils.mkdir_p(config[:tmpdir])
    puts "downloading #{href} to #{csv_file}"
    start = Time.now
    File.open(csv_file, 'w') do |file|
      Net::HTTP.new(href.host, href.port).request_get(href.path) do |response|
        total_length = response['Content-Length'].to_i
        print "  reading #{(total_length/1024.0/1024).round(1)} MB: "

        response.read_body do |chunk|
          file.write chunk
          status(chunk.length, total_length)
        end
      end
    end
    stop = Time.now
    elapsed = stop + 0.000001 - start # fudge to prevent division by zero

    puts "\n  read #{@current_byte} bytes in #{elapsed.round(2)} seconds at " +
         "#{(@current_byte/1024/elapsed).round(1)} KB/sec"
  end

  def read_ranges countries
    File.open(csv_file, 'r') do |file|
      gz = Zlib::GzipReader.new(file)
      CSV.new(gz, headers: false).each do |row|
        countries.each do |name, country_codes|
          if country_codes.include?(row[2])
            yield name, row[0], row[1]
          end
        end
      end
    end
  end
end
