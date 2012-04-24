require 'rakuten'
require 'uri'

module Jekyll
  class RakutenResultCache
    def initialize
      @result_cache = {}
      @client = Rakuten::Client.new(ENV["RAKUTEN_DEVELOPER_ID"], ENV["RAKUTEN_AFFILIATE_ID"])
    end

    @@instance = RakutenResultCache.new

    def self.instance
      @@instance
    end

    def item_code_search(item_code)
      item_code.strip!
      return @result_cache[item_code] if @result_cache.has_key?(item_code)
      item = @client.item_code_search('2010-08-05', {:itemCode => item_code})["Items"]["Item"][0]
      @result_cache[item_code] = item
      return item
    end

    private_class_method :new
  end

  module Filters
    def rakuten_large_image(text)
      item = RakutenResultCache.instance.item_code_search(text)
      uri  = URI(item["mediumImageUrl"])
      uri  = sprintf("%s://%s:%s%s", uri.scheme, uri.host, uri.port, uri.path)
      '<a href="%s"><img src="%s" /></a>' % [item["affiliateUrl"], uri]
    end

    def rakuten_medium_image(text)
      item = RakutenResultCache.instance.item_code_search(text)
      '<a href="%s"><img src="%s" /></a>' % [item["affiliateUrl"], item["mediumImageUrl"]]
    end

    def rakuten_small_image(text)
      item = RakutenResultCache.instance.item_code_search(text)
      '<a href="%s"><img src="%s" /></a>' % [item["affiliateUrl"], item["smallImageUrl"]]
    end

    def rakuten_link(text)
      item = RakutenResultCache.instance.item_code_search(text)
      '<a href="%s">%s</a>' % [item["affiliateUrl"], item["itemName"]]
    end
  end

end
