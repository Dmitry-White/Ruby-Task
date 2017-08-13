require 'curb'
require 'nokogiri'


http = Curl.get("http://www.petsonic.com/es/perros/snacks-y-huesos-perro")

puts http.bidy_str

#html = Nokogiri::HTML(http.body_str)

