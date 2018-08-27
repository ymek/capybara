# frozen_string_literal: true

module Capybara
  module Node
    ##
    #
    # A {Capybara::Document} represents an HTML document. Any operation
    # performed on it will be performed on the entire document.
    #
    # @see Capybara::Node
    #
    class Document < Base
      include Capybara::Node::DocumentMatchers

      def inspect
        %(#<Capybara::Document>)
      end

      ##
      #
      # @!method text(type)
      # @return [String]    The text of the document
      #
      def text(type = nil, **options)
        root = find(:xpath, '/html')
        # The options are here to support the never documented, and deprecated :normalize_ws option
        # TODO: remove options at next available chance
        root.text(type, options)
      end

      ##
      #
      # @return [String]    The title of the document
      #
      def title
        session.driver.title
      end
    end
  end
end
