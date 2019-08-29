module SuperPDF
  module Renderer
    module Helper
      include ::Prawn::Measurements

      REGEX_PERCENTAGE = /\A(?<percentage>\d+)%\z/
      REGEX_COLOR_CODE = /\A#(?<color>\S+)\z/
      REGEX_BORDER_OPTION = /\A(?<width>[0-9.]+)(?<unit>mm|cm|dm|m|in|yd|ft|pt)\s(?<style>\S+)\s(?<color>\S+)\z/

      def percent2pt(value, base_length)
        number = value.match(REGEX_PERCENTAGE)[:percentage]
        base_length * (number.to_f / 100)
      end

      def percent2pt_of_width(value)
        percent2pt(value, bounds.width)
      end

      def percent2pt_of_height(value)
        percent2pt(value, bounds.height)
      end

      def percentage?(value)
        return false unless value.is_a?(String)
        value.match(REGEX_PERCENTAGE)
      end

      # Examples:
      #   #333 -> 333333
      #   #333333 -> 333333
      def full_color_code(color)
        matched = color.match(REGEX_COLOR_CODE)
        raise ArgumentError, 'Ex: #222' if matched.nil?
        case matched[:color].length
        when 3; matched[:color] * 2
        when 6; matched[:color]
        else
          raise ArgumentError, "Wrong color code, ex: #333 | #333333"
        end
      end

      # Examples:
      #   4
      #   [2, 4]
      #   [2, 4, 2, 4]
      def convert_padding(value)
        values = Array(value)
        sides = %i[top right bottom left]

        # Treat :margin as CSS shorthand with 1-4 values.
        positions = {
          4 => [0, 1, 2, 3], 3 => [0, 1, 2, 1],
          2 => [0, 1, 0, 1], 1 => [0, 0, 0, 0],
          0 => []
        }[values.length]

        top, right, bottom, left = sides.zip(positions).map do |side, pos|
          pos ? values[pos] : 0
        end

        OpenStruct.new(top: top, right: right, bottom: bottom, left: left)
      end
      alias_method :convert_margin, :convert_padding

      # "1pt solid #222"      => width: 1, style: solid,  color: 222222
      # "2pt dashed #fff000"  => width: 2, style: dashed, color: fff000
      # "3pt dotted #444"     => width: 3, style: dotted, color: 444444
      def convert_border_options(setting)
        case setting
        when TrueClass
          { color: '000000', style: 'solid', width: 1 }
        when String
          matched = setting.match(REGEX_BORDER_OPTION)
          raise ArgumentError if matched.nil?
          {
            color: full_color_code(matched[:color]),
            style: matched[:style],
            width: convert_numeric(matched[:width].to_f, matched[:unit])
          }
        when Hash
          setting
        end
      end

      def convert_numeric(n, unit)
        case unit
        when 'mm'; mm2pt(n)
        when 'cm'; cm2pt(n)
        when 'dm'; dm2pt(n)
        when 'm' ; m2pt(n)
        when 'in'; in2pt(n)
        when 'yd'; yd2pt(n)
        when 'ft'; ft2pt(n)
        when 'pt'; pt2pt(n)
        else
          raise ArgumentError, "Unknow unit `#{unit}`"
        end
      end
    end
  end
end
