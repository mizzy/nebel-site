guard 'shell' do
  watch(/layouts\/(.+)/) { `stellar` }
  watch(/static\/(.+)/)  { `stellar` }
  watch(/posts\/(.+)/)   { `stellar` }
  watch(/plugins\/(.+)/) { `stellar` }
end

guard 'livereload' do
  watch(%r{layouts/(.+)})
  watch(%r{static/(.+)})
  watch(%r{posts/(.+\.md$)})
  watch(%r{posts/(.+\.markdown$)})
  watch(%r{plugins/(.+)})
end
