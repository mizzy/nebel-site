require 'bundler/setup'

class Post < Thor
  desc "create", "create new post"
  def create(title)
    time = Time.now
    file = sprintf "posts/%04d-%02d-%02d-%s.markdown", time.year, time.month, time.day, title
    File.open(file, "w") do |f|
      f.puts "---"
      f.puts "title: #{title}"
      f.puts "date: #{time}"
      f.puts "---"
    end
    `open #{file}`
  end
end
