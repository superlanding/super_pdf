require 'prawn'
require 'prawn/table'

module SuperPDF
  class Document < ::Prawn::Document
    attr_accessor :default_font_family
    include Renderer
  end
end
