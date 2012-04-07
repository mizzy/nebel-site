# A Liquid tag rof Jekyll sites that allows embedding TWAN images.
# http://www.twanight.org/newTWAN/index.asp
# by: Gosuke Miyashita
#
# Example usage: {% twan 3003406 %} // {% twan photo_id %}

require 'open-uri'

module Jekyll
  class TwanTag < Liquid::Tag
    def initialize(tag_name, id, token)
      super
      @id = id.strip
      @cache_dir = File.expand_path "../.twan-cache", File.dirname(__FILE__)
      @image_dir = File.expand_path "../static/images/twan", File.dirname(__FILE__)
      FileUtils.mkdir_p @cache_dir
      FileUtils.mkdir_p @image_dir
    end

    def render(context)
      get_image(@id)
      url     = 'http://www.twanight.org/newTWAN/photos.asp?ID=' + @id
      html    = get_cached_html(@id) || get_html_from_web(@id)
      img_url = "/images/twan/#{@id}.jpg"
      title   = html.match(/<font color="#800000">(.+)<\/font>/)[1]
      author  = html.match(/<a href="photographers_about.asp\?photographer=.+">(.+)<\/a>/)[1]

      <<-HTML
<a href="#{url}"><img src="#{img_url}" /></a></br />
<a href="#{url}">#{title} by #{author}</a>
      HTML
    end

    def get_image(id)
      image_file = File.join @image_dir, "#{id}.jpg"
      return if File.exist? image_file
      img = open("http://www.twanight.org/newTWAN/photos/#{id}.jpg")
      File.open(image_file, "w") do |io|
        io.write img.read
      end
    end

    def get_cached_html(id)
      cache_file = File.join @cache_dir, id
      File.read cache_file if File.exist? cache_file
    end

    def get_html_from_web(id)
      html = open('http://www.twanight.org/newTWAN/photos.asp?ID=' + id).read
      cache_file = File.join @cache_dir, id
      File.open(cache_file, "w") do |io|
        io.write html
      end
      html
    end

  end
end

Liquid::Template.register_tag('twan', Jekyll::TwanTag)
