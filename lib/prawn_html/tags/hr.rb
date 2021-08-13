# frozen_string_literal: true

module PrawnHtml
  module Tags
    class Hr < Tag
      ELEMENTS = [:hr].freeze

      MARGIN_BOTTOM = 12
      MARGIN_TOP = 6

      def block?
        true
      end

      def custom_render(pdf, _context)
        dash = parse_dash_value(attrs.data['dash']) if attrs.data.include?('dash')
        pdf.dash(dash) if dash
        pdf.stroke_horizontal_rule
        pdf.undash if dash
      end

      def extra_attrs
        @extra_attrs ||= {
          'margin-bottom' => MARGIN_BOTTOM.to_s,
          'margin-top' => MARGIN_TOP.to_s,
        }
      end

      private

      def parse_dash_value(dash_string)
        if dash_string.match? /\A\d+\Z/
          dash_string.to_i
        else
          dash_array = dash_string.split(',')
          dash_array.map(&:to_i) if dash_array.any?
        end
      end
    end
  end
end
