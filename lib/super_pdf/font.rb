module SuperPDF
  module Font
    extend ActiveSupport::Concern

    FAMILIES = {}

    included do
      delegate :default_font_family, to: :class
    end

    class_methods do
      attr_reader :default_font_family

      def default_font(key)
        @default_font_family = key
      end
    end
  end
end
