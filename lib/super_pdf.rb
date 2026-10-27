require 'prawn'
require 'ostruct'
require 'active_support'
require 'active_support/concern'
require 'active_support/core_ext/module/delegation'
require "super_pdf/version"
require "super_pdf/page"
require "super_pdf/font"
require "super_pdf/renderer"
require "super_pdf/enhance"

module SuperPDF

  class << self
    def extension_add(base)
      Prawn::Document.extensions << base
    end

    def extensions
      Prawn::Document.extensions
    end
  end
end
