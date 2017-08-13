require 'nokogiri'
require 'curb'
require 'csv'

url = Curl.get("http://www.petsonic.com/es/perros/snacks-y-huesos-perro") do |curl|
  curl.verbose = true
  curl.follow_location = true
  curl.ssl_verify_peer = false
end

html = Nokogiri::HTML(url.body_str)

puts html

File.open("script_output.html", "w") do |file|
  file << html
end
