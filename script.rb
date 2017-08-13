require 'curb'
require 'nokogiri'

http = Curl::Easy.new("http://www.petsonic.com/es/perros/snacks-y-huesos-perro") do |curl|
  curl.verbose = true
  curl.ssl_verify_host = false
end
http.perform
puts http.body_str




#html = Nokogiri::HTML(http.body_str)

