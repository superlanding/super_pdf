module SuperPDF
  module Renderer
    class Rows
      attr_reader :rows, :pdf

      def initialize(pdf)
        @pdf = pdf
      end

      def row(&block)
        row = Row.new(pdf.cursor, pdf)
        rows << row

        block.call(row)

        rows.pop
      end

      def rows
        @rows ||= []
      end
    end

    class Row
      attr_reader :cursor, :pdf

      def initialize(cursor, pdf)
        @cursor = cursor
        @pdf = pdf
      end

      def column(options, &block)
        @left_pos ||= pdf.bounds.left
        width = options.delete(:width)
        width = pdf.percent2pt_of_width(width) if pdf.percentage?(width)
        pdf.bounding_box([@left_pos, pdf.bounds.top], width: width, height: pdf.bounds.height) do
          pdf.div(options) do
            @left_pos += pdf.bounds.width
            yield
          end
        end

        fallback_cursor
      end

      def fallback_cursor
        pdf.move_cursor_to cursor
      end
    end
  end
end
