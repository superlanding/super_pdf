require 'test_helper'

class FontTest < Minitest::Test

  SuperPDF::Font::FAMILIES[:MSJH] = { normal: File.expand_path('../support/font/MSJH.ttf', __FILE__) }

  class FakePDF
    include SuperPDF::Font

    default_font :MSJH
  end

  def test_font_setting
    assert_equal(:MSJH, FakePDF.new.default_font_family)
  end
end
