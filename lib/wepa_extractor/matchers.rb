module WepaExtractor
  # Matcher enables to find (match) particular element on the Web Page
  # (usually Nokogiri node).
  #
  # Matcher has implement #call method wihich takes part of the web pages
  # and returns matched subpart of input.
  # Can return one of:
  #  * string - e.g. direct returned vale
  #  * array of founded nodes.
  module Matcher
    # Abstract class for matcher
    class BasicMatcher
      attr_reader :selector
      def initialize(selector)
        @selector = selector
      end

      def inspect
        "#<#{self.class.to_s.sub(/^.*::/, '')}:#{@selector.inspect}>"
      end

      def as_json
        { selector: selector, type: self.class.to_s.sub(/^.*::/, '') }
      end

      def call(_node)
        fail 'Has to be implemented in sub-class!'
      end
    end

    class Css < BasicMatcher
      def call(node)
        node.css(@selector)
      end
    end

    class Xpath < BasicMatcher
      def call(node)
        node.xpath(@selector)
      end
    end

    # class URL < BasicMatcher
    #  def call(node, base_url = nil)
    #    URI.join(base_url, node.xpath(@selector).first.xpath('string(@href)'))
    #  end
    # end

    class Const < BasicMatcher
      def call(_node)
        @selector
      end
    end

    # use for setting result to parent Schema
    # class Parent < Const
    # end
  end
end
