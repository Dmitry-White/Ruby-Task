require 'nokogiri'
require 'curb'
require 'csv'


#------------------ Reading Input -------------------------------
ARGC = ARGV.length
if ARGC < 2 or ARGC > 2
  puts "Usage: ruby <input_file> <output_file> <URL>"
  abort
end

output = ARGV[0]
address = ARGV[1]
#----------------------------------------------------------------


#---------------- Functions Definitions -------------------------
def get_html(link)
  url = Curl.get(link) do |curl|
    #curl.verbose = true
    curl.follow_location = true
    curl.ssl_verify_peer = false
  end
  html = Nokogiri::HTML(url.body_str)
  html
end
# ---------------------------------------------------------------


html = get_html(address)
url = html.xpath('//link[@rel="canonical"]/@href').to_s


another_page = true
page_num = 1

#------------------- Scraping with Xpath -------------------------
url_list = Array.new
while another_page == true

  urls = Array.new
  html.xpath('//div/h5/a/@href').each do |url|
    urls << url
  end
  url_list << urls

  #-------------------- Checking for the next page --------------------------
  disabled_right_button = html.xpath('boolean(//li[@id="pagination_next_bottom" and not(@class="disabled pagination_next")])')
  if disabled_right_button
    html = get_html(url + "?p=#{page_num+1}")
  else
    another_page = false
  end
  #--------------------------------------------------------------------------


  puts "Added product links from page " + page_num.to_s
  page_num += 1
end
#-----------------------------------------------------------------

puts "Pages are listed. Beginning scrapping sequence."

len = url_list.length

#------------------- Write file with list of page links ----------
File.open("url_output.txt", "wb") do |file|
  (0..len-1).each do |index|
    file.puts(url_list[index])
  end
end
#-----------------------------------------------------------------


#-------------------- Search for products details ------------------
url_list = File.readlines('titles_output.txt')
product_num = 1

url_list.each do |link|
  link = link.strip
  product_html = get_html(link)

  product_name = product_html.xpath('//div[@class="product-name"]/h1/text()')
  product_weights = product_html.xpath('//li/span[@class="attribute_name"]/text()')
  product_prices = product_html.xpath('//li/span[@class="attribute_price"]/text()')
  product_images = product_html.xpath('//a[@data-fancybox-group="other-views"]/@href')


  #--------------------------- Write CSV file ---------------------------------------
  CSV.open(output, 'a') do |row|
    (0..product_weights.length-1).each do |index|
      row << ['Name: ', product_name.to_s.strip + ' - '  + product_weights[index].to_s]
      row << ['Price: ', product_prices[index].to_str]
      row << ['Image: ', product_images[index]]
      row << ['-----------------------------------------------------------------------------']
    end
  end
  #----------------------------------------------------------------------------------


  puts "Description of product " + product_num.to_s + " added to .csv file."
  product_num += 1
end
#-------------------------------------------------------------------------
