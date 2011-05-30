require 'open-uri'

require 'active_support/builder' unless defined?(Builder)


class DealzController < ApplicationController
  
  def parse_response(url)   
    puts url
    url = URI.escape(url)
    doc = Nokogiri::HTML(open(url))

    framerow=doc.search("iframe[@id='price']")
    src=""
    framerow.each do |r|
          u=r['src']
          src=u
        #  puts 'src='+u
        end


    #http://www.dealoz.com/price_load.pl?cat=book&data_id=14370575&op=buy&class=all&sort=localized_price:asc&rcount=2"
    #url = "http://www.dealoz.com/price.pl?cat=book&data_id=14370575&op=buy&class=all&sort=localized_price:asc"
    
    uri = "http://www.dealoz.com"+src+"&sort=localized_price:asc"
    puts "before uri="+uri
    uri = uri.gsub("price_load", "price")
    uri = URI.escape(uri)
    puts "uri="+uri
    puts "=========="
    
   # doc = Nokogiri::HTML(open(uri, :read_timeout=>20))
    doc = Nokogiri::HTML(open(uri))
    xml = Builder::XmlMarkup.new(:indent=>2)
    xml.instruct!
   # puts doc

    rows = doc.xpath("//table[@class='offer']/tr")
    name=""

    xml.root do
      (1...rows.length-1).to_a.each do |i|
        node=rows[i]
        condition = node.search("div[@class='condition']")
        price_button = node.search("a[@class='price_button']")
        store = (node.search("td[class='unit']/a[@class='jt']"))
    
        if store.size==0
          store = store = (node.search("td[class='unit']/table/tr/td/a[@class='jt']"))
        end
        store.each do |s|
          name=""
 
          if s['title'].nil?
            nstore = (node.search("td[class='unit']/table/tr/td/a[@class='jt']"))
            if nstore.size>0
              nstore.each do |sn|
                name=sn['title']
              end
            else
              alink_row=(node.search("td[class='unit']/a[@id='store_link_jquery']"))
              if alink_row.size>0
                alink_row.each do |n|
                  name=n['title']
                end
              else
              end
            end
          else
            name=s['title']
          end

          p1=name.index('>')
          p2=name.rindex('<')
          name=name[p1+1..p2-1]    
        end
  
        xml.deal do
          xml.title CGI::unescapeHTML(name)
          xml.price price_button.text
          xml.condition condition.text
        end
end
      end
    end

  def dealz
  #  url = "http://dealoz.com/price.pl?cat=book&data_id="+params['isbn']+"&op=buy&class=all&sort=localized_price:asc"
   
    # 10 char isbn
    
    # url = "http://dealoz.com/prod2.pl?cat=book&op=buy&op2=buy&lang=en-us&search_country=us&shipto=us&cur=usd&zip=&nw=y&class=&pqcs=&quantity=&shipping_type=&sort=&catby=book.keyword&asin=1430215968&upc=&mpn=&mfr="

    # 13 char isbn
#    url = "http://www.dealoz.com/prod2.pl?cat=book&op=buy&op2=buy&lang=en-us&search_country=us&shipto=us&cur=usd&zip=&nw=y&class=&pqcs=&quantity=&shipping_type=&sort=&catby=book.keyword&asin=&ean="+params['isbn']+"&upc=&mpn=&mfr="

    isbn=params['isbn']
    isbn=isbn.upcase
    
    puts '-----------'+isbn
    
    if isbn.length==10
      url = "http://www.dealoz.com/prod2.pl?cat=book&op=buy&op2=buy&lang=en-us&search_country=us&shipto=us&cur=usd&zip=&nw=y&class=&pqcs=&quantity=&shipping_type=&sort=&catby=book.keyword&asin="+isbn+"&upc=&mpn=&mfr="

    else
       url = "http://www.dealoz.com/prod2.pl?cat=book&op=buy&op2=buy&lang=en-us&search_country=us&shipto=us&cur=usd&zip=&nw=y&class=&pqcs=&quantity=&shipping_type=&sort=&catby=book.keyword&asin=&ean="+isbn+"&upc=&mpn=&mfr="
    end

    #url = "http://www.dealoz.com/prod2.pl?cat=book&op=buy&op2=buy&lang=en-us&search_country=us&shipto=us&cur=usd&zip=&nw=y&class=&pqcs=&quantity=&shipping_type=&sort=&catby=book.keyword&asin=&ean="+params['isbn']+"&upc=&mpn=&mfr="

    puts url
    
    @str= parse_response(url)
    puts @str
    render :xml=> @str
  end

  
end
