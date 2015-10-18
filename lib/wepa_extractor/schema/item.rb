require 'wepa_extractor/schema/item'

class WepaExtractor::Schema
  # Defines one item to be extracted by the schema
  #
  # Schema consist of:
  # * key matcher  -- defines key under the extracted value will be stored
  # * value matche -- defines how to extract value
  # * inner schema -- schema to be applied to the value
  # options:
  # * multi
  # * merge_array
  # * debug
  class Item
    attr_reader :key_matcher, :value_matcher, :inner_schema
    attr_reader :multi, :merge_array, :debug

    def initialize(key_matcher, value_matcher, opts = {})
      @key_matcher = key_matcher
      @value_matcher = value_matcher
      @inner_schema = opts[:inner_schema]

      @multi = opts[:multi] || false
      @merge_array = opts[:merge_array] || false
      @debug = opts[:debug] || false
    end

    def to_s
      t = custom_options
      t[:inner_schema] = inner_schema.to_s if inner_schema
      'Item(%s, %s, %s)' % [
        key_matcher.inspect,
        value_matcher.inspect,
        t.inspect
      ]
    end

    def as_json
      schema_hash = {
        key: key_matcher.as_json,
        value: value_matcher.as_json
      }
      schema_hash[:inner_schema] = inner_schema.as_json if inner_schema
      custom_options.merge(schema_hash)
    end

    def merge_up?
      (WepaExtractor::Matcher::Const === key_matcher) &&
        (key_matcher.selector == '^')
    end

    def call(node)
      key = extract_key(node)
      value = extract_value(node)

      [key, value]
    end

    def extract_key(node)
      key_node = key_matcher.call(node)
      return key_node if String === key_node

      count = key_node.count
      unless count == 1
        fail "Non-atomic match for #{key_matcher.inspect}, found #{count} results"
      end

      # return first (e.g. the only one) node
      result = key_node.first
      normalize_node(result)
    end

    def extract_value(node)
      value_node = value_matcher.call(node)
      value = normalize_value(value_node)

      count = value.count
      if !multi && count != 1
        fail "Non-atomic match for #{value_matcher.inspect}, found #{count} results"
      end

      value = merge_array_helper(value) if (Array === value) && merge_array
      value = value.first unless multi
      value
    end

    private

    # Node should be HTML node (currently Nokogiri) or String
    # in case of Node it is neccessary to get only text
    def normalize_node(node_or_string)
      String === node_or_string ? node_or_string : node_or_string.text
    end

    def normalize_value(value)
      value = [value] unless Array === value
      value.map do |vn|
        inner_schema ? inner_schema.call(vn) : normalize_node(vn)
      end
    end

    def merge_array_helper(values)
      values.each_with_object({}) { |i, o| o.merge!(i) }
    end

    def custom_options
      res = {}
      res[:multi] = true if multi
      res[:merge_array] = true if merge_array
      res[:debug] = true if debug
      res
    end
  end
end
