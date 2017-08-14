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

puts 'Input received. Getting source html file.'
#----------------------------------------------------------------


#---------------- Nokogiri Parse Function  -------------------------
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

puts 'Source html file received.'

another_page = true
page_num = 1
urls_num = 0

puts 'Initiating page URL listing sequence.'
#------------------- Scrap with Xpath -------------------------
url_list = Array.new
while another_page == true

  numb = 0
  urls = Array.new
  html.xpath('//div/h5/a/@href').each do |url|
    urls << url
    numb += 1
  end
  urls_num += numb
  url_list << urls
  #-------------------- Check for the next page --------------------------
  disabled_right_button = html.xpath('boolean(//li[@id="pagination_next_bottom" and not(@class="disabled pagination_next")])')
  if disabled_right_button
    html = get_html(url + "?p=#{page_num+1}")
  else
    another_page = false
  end
  #--------------------------------------------------------------------------


  puts "      Added product links from page " + page_num.to_s
  page_num += 1
end
#-----------------------------------------------------------------
len = url_list.length

puts 'Pages are listed. Total number of links: ' + urls_num.to_s



#------------------- Write file with list of page links ----------
link_num=0
File.open("url_output.txt", "wb") do |file|
  (0..len-1).each do |index|
    file.puts(url_list[index])
    link_num += 1
  end
end
#-----------------------------------------------------------------

puts 'Initiating scrapping sequence.'

#-------------------- Search for products details ------------------
url_list = File.readlines('url_output.txt')
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


  puts "      Description of product " + product_num.to_s + " added to .csv file."
  product_num += 1


  #-------------------- Limit number of links scrapped--------------------
  if product_num == 50
    break
  end
  #-----------------------------------------------------------------------

end
puts 'Scraping complete. Refer to ' + ARGV[0] + ' file for script output.'
#-------------------------------------------------------------------------
