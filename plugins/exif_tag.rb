# -*- coding: utf-8 -*-
# A Liquid tag rof Jekyll sites that allows showing exif data.
# by: Gosuke Miyashita
#
# Example usage: {% exif /images/sample.jpg %}

require 'exifr'

module Jekyll
  class ExifTag < Liquid::Tag
    def initialize(tag_name, file, token)
      super
      @image_file = File.expand_path "../static" + file.strip , File.dirname(__FILE__)
    end

    def render(context)
      exif = EXIFR::JPEG::new(@image_file)
      <<-HTML
焦点距離 #{exif.focal_length.to_i} mm F#{sprintf "%.1f", exif.f_number.to_f} #{exif.model} ISO #{exif.iso_speed_ratings} #{exif.exposure_time.to_i} 秒露光 #{exif.date_time_original}
      HTML
    end
  end
end

Liquid::Template.register_tag('exif', Jekyll::ExifTag)
