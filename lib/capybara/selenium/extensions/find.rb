# frozen_string_literal: true

module Capybara
  module Selenium
    module Find
      def find_xpath(selector, uses_visibility: false, styles: nil, **_options)
        find_by(:xpath, selector, uses_visibility: uses_visibility, texts: [], styles: styles)
      end

      def find_css(selector, uses_visibility: false, texts: [], styles: nil, **_options)
        find_by(:css, selector, uses_visibility: uses_visibility, texts: texts, styles: styles)
      end

    private

      def find_by(format, selector, uses_visibility:, texts:, styles:)
        els = find_context.find_elements(format, selector)
        els = filter_by_text(els, texts) if (els.size > 1) && !texts.empty?
        visibilities = uses_visibility && els.size > 1 ? element_visibilities(els) : []
        styles = if styles.is_a?(Hash)
          element_styles(els, styles.keys)
        else
          []
        end
        els.map.with_index { |el, idx| build_node(el, visible: visibilities[idx], style: styles[idx]) }
      end

      def element_visibilities(elements)
        es_context = respond_to?(:execute_script) ? self : driver
        es_context.execute_script <<~JS, elements
          return arguments[0].map(#{is_displayed_atom})
        JS
      end

      def element_styles(elements, styles)
        es_context = respond_to?(:execute_script) ? self : driver
        es_context.execute_script <<~JS, elements, styles
          var elements = arguments[0];
          var styles = arguments[1];
          return elements.map(function(el){
            var el_styles = window.getComputedStyle(el);
            return styles.reduce(function(res, style){
              res[style] = el_styles[style];
              return res;
            }, {})
          })
        JS
      end

      def filter_by_text(elements, texts)
        es_context = respond_to?(:execute_script) ? self : driver
        es_context.execute_script <<~JS, elements, texts
          var texts = arguments[1]
          return arguments[0].filter(function(el){
            var content = el.textContent.toLowerCase();
            return texts.every(function(txt){ return content.indexOf(txt.toLowerCase()) != -1 });
          })
        JS
      end

      def is_displayed_atom # rubocop:disable Naming/PredicateName
        @is_displayed_atom ||= browser.send(:bridge).send(:read_atom, 'isDisplayed')
      end
    end
  end
end
