# A Liquid tag for Jekyll sites that allows embedding vimeo movies
# by: Gosuke Miyashita
#
# Example usage: {% vimeo 28040685 800 600 %}

require 'open-uri'
require 'multi_json' 

module Jekyll
  class VimeoTag < Liquid::Tag
    def initialize(tag_name, text, token)
      super
      @text = text
      @cache_dir = File.expand_path "../.vimeo-cache", File.dirname(__FILE__)
      FileUtils.mkdir_p @cache_dir
    end

    def render(context)
      if parts = @text.match(/(\d+) (\d+) (\d+)/)
        id, width, height = parts[1].strip, parts[2].strip, parts[3].strip
      end

      vimeo = get_vimeo(id)
      <<-HTML
<iframe src="http://player.vimeo.com/video/#{id}?color=ffffff" width="#{width}" height="#{height}" frameborder="0" webkitAllowFullScreen allowFullScreen></iframe><p><a href="http://vimeo.com/#{id}">#{vimeo["title"]}</a> from <a href="#{vimeo["author_url"]}">#{vimeo["author_name"]}</a> on <a href="http://vimeo.com">Vimeo</a>.</p>
      HTML
    end

    def get_vimeo(id)
      cache_file = File.join @cache_dir, id
      if File.exist? cache_file
        MultiJson.decode(File.read cache_file)
      else
        json = open("http://vimeo.com/api/oembed.json?url=http%3A//vimeo.com/#{id}").read
        File.open(cache_file, "w") do |io|
          io.write json
        end
        MultiJson.decode(json)
      end
    end

  end
end

Liquid::Template.register_tag('vimeo', Jekyll::VimeoTag)
