guard 'shell' do
  watch(/layouts\/(.+)/) { `nebel` }
  watch(/static\/(.+)/)  { `nebel` }
  watch(/posts\/(.+)/)   { `nebel` }
  watch(/plugins\/(.+)/) { `nebel` }
end

guard 'livereload' do
  watch(%r{layouts/(.+)})
  watch(%r{static/(.+)})
  watch(%r{posts/(.+\.md$)})
  watch(%r{posts/(.+\.markdown$)})
  watch(%r{plugins/(.+)})
end
