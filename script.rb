require 'nokogiri'
require 'curb'
require 'csv'

address = "http://www.petsonic.com/es/perros/snacks-y-huesos-perro"
url_list = Array.new

#---------------- Functions Definitions ----------------
def get_html(link)
  url = Curl.get(link) do |curl|
    curl.verbose = true
    curl.follow_location = true
    curl.ssl_verify_peer = false
  end
  html = Nokogiri::HTML(url.body_str)
  html
end
# ------------------------------------------------------

html = get_html(address)
url = html.xpath('//link[@rel="canonical"]/@href').to_s


another_page = true
page_num = 1

#------------------- Scraping with Xpath ----------------
while another_page == true
  urls = Array.new

  html.xpath('//div/h5/a/@href').each do |url|
    urls << url
  end

  #puts urls
  url_list << urls

  #-------------------------------------------------------


  #-------------------- Checking for the next page -------
  disabled_right_button = html.xpath('boolean(//li[@id="pagination_next_bottom" and not(@class="disabled pagination_next")])')

  if disabled_right_button
    html = get_html(url + "?p=#{page_num+1}")
  else
    another_page = false
    puts "HEEEEEEEEEEEEY"
  end

  page_num += 1
end
#-------------------------------------------------------

File.open("titles_output.txt", "wb") do |file|
  (0..url_list.length-1).each do |index|
    file.puts(url_list[index])
  end
end

puts url_list




#puts html
=begin
CSV.open("titles.csv", "wb") do |row|
  (0..titles.length - 1).each do |index|
    row << ["Title",titles[index]]
  end
end
=end

