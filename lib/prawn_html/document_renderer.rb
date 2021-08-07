# frozen_string_literal: true

module PrawnHtml
  class DocumentRenderer
    NEW_LINE = { text: "\n" }.freeze
    SPACE = { text: ' ' }.freeze

    # Init the DocumentRenderer
    #
    # @param pdf [Prawn::Document] target Prawn PDF document
    def initialize(pdf)
      @buffer = []
      @context = Context.new
      @doc_styles = {}
      @pdf = pdf
    end

    # Assigns the document styles
    #
    # @param styles [Hash] styles hash with CSS selectors as keys and rules as values
    def assign_document_styles(styles)
      @doc_styles = styles.transform_values do |style_rules|
        Attributes.new(style: style_rules).styles
      end
    end

    # On tag close callback
    #
    # @param element
    def on_tag_close(element)
      render_if_needed(element)
      context.last_text_node = false
      context.pop
    end

    # On tag open callback
    #
    # @param tag [String] the tag name of the opening element
    # @param attributes [Hash] an hash of the element attributes
    def on_tag_open(tag, attributes)
      setup_element(tag)
    end

    # On text node callback
    #
    # @param content [String] the text node content
    #
    # @return [NilClass] nil value (=> no element)
    def on_text_node(content)
      return if content.match?(/\A\s*\Z/)

      text = content.gsub(/\A\s*\n\s*|\s*\n\s*\Z/, '').delete("\n").squeeze(' ')
      buffer << { text: text }
      context.last_text_node = true
      nil
    end

    # Render the buffer content to the PDF document
    def render
      return if buffer.empty?

      options = context.merge_options
      output_content(buffer.dup, options)
      buffer.clear
    end

    alias_method :flush, :render

    private

    attr_reader :buffer, :context, :pdf

    def render_if_needed(element)
      render_needed = buffer.any? && buffer.last != NEW_LINE
      return false unless render_needed

      render
      true
    end

    def setup_element(element)
      add_space_if_needed unless render_if_needed(element)
      context.push(element)
    end

    def add_space_if_needed
      buffer << SPACE if buffer.any? && !context.last_text_node && ![NEW_LINE, SPACE].include?(buffer.last)
    end

    def output_content(buffer, options)
      pdf.formatted_text(buffer, options)
    end
  end
end
