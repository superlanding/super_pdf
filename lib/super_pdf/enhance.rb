require "super_pdf/document"

module SuperPDF
  module Enhance
    extend ActiveSupport::Concern

    included do
      include Font
      include Page

      def pdf
        @pdf ||= Document.new(
          page_size: page_size,
          skip_page_creation: true,
          margin: 0
        ).tap do |document|
          document.font_families.update(Font::FAMILIES) unless Font::FAMILIES.empty?
          document.default_font_family = default_font_family
        end
      end
    end
  end
end
