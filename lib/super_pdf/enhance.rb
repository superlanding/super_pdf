require 'prawn'
require 'prawn/table'
require 'prawn/icon'

module SuperPDF
  module Enhance
    extend ActiveSupport::Concern

    included do
      include Font
      include Page

      def pdf
        @pdf ||= document_klass.new(
          page_size: page_size,
          skip_page_creation: true,
          margin: 0
        ).tap do |document|
          document.font_families.update(Font::FAMILIES) unless Font::FAMILIES.empty?
          document.default_font_family = default_font_family
        end
      end

      protected

      def document_klass
        @document_klass ||= Class.new(::Prawn::Document) do
          attr_accessor :default_font_family
          include Renderer
        end
      end
    end
  end
end
