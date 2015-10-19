$LOAD_PATH << '../lib' << 'lib'

require 'wepa_extractor'
require 'pp'

page_content = File.read('example/page.html')

schema_items = [
  WepaExtractor::Schema::Item.new(
    WepaExtractor::Matcher::Const.new('my_key'),
    WepaExtractor::Matcher::Css.new('.extract-this')
  )
]

schema = WepaExtractor::Schema.new(
  'text',
  schema_items
)

puts 'YAML representation:'
puts schema.to_yaml

puts 'Found:'
pp schema.call(page_content)
