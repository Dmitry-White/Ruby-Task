require 'nokogiri'
require 'curb'
require 'csv'

url = Curl.get("http://www.petsonic.com/es/perros/snacks-y-huesos-perro") do |curl|
  curl.verbose = true
  curl.follow_location = true
  curl.ssl_verify_peer = false
end

html = Nokogiri::HTML(url.body_str)

titles = Array.new

html.xpath('//div/h5/a/text()').each do |title|
  titles << title
end

puts titles


File.open("titles_output.txt", "wb") do |file|
  (0..titles.length-1).each do |index|
    file.puts(titles[index])
  end
end


