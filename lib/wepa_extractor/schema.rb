require 'nokogiri'
require 'yaml'
require 'wepa_extractor/schema/item'

module WepaExtractor
  class Schema
    attr_reader :content_type, :schema_items

    def initialize(content_type, schema_items)
      @content_type = content_type
      @schema_items = schema_items
    end

    def as_json
      {
        type: content_type,
        schema_items: schema_items.map(&:as_json)
      }
    end

    def call(content)
      document = prepare_document(content)

      schema_items.each_with_object({}) do |item, res|
        key, value = item.call(document)
        if item.merge_up?
          res.merge(value)
        else
          res[key] = value
        end
      end
    end

    def prepare_document(content)
      case content_type
      when 'html' then content
      when 'text' then Nokogiri::HTML(content)
      when 'url'
        doc = Nokogiri::HTML.parse(open(content), content)
        doc
      else
        fail "Unknown content type: #{content_type.inspect}"
      end
    end

    def to_yaml
      YAML.dump(as_json)
    end
  end
end
