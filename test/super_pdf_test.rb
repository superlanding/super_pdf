require 'test_helper'

class SuperPDFTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::SuperPDF::VERSION
  end

  SuperPDF::Page::SIZE['10x10'] = [283, 283]
  SuperPDF::Font::FAMILIES[:MSJH] = { normal: File.expand_path('../support/font/MSJH.ttf', __FILE__) }

  class FakePDF
    include SuperPDF::Enhance

    page_size '10x10'
    default_font :MSJH
  end

  def test_pdf_page_size
    @pdf = FakePDF.new.pdf
    assert_equal(283, @pdf.bounds.width)
    assert_equal(283, @pdf.bounds.height)
  end

  def test_pdf_default_font
    @pdf = FakePDF.new.pdf
    assert_equal(:MSJH, @pdf.default_font_family)
  end

  def test_pdf_font_families
    @pdf = FakePDF.new.pdf
    assert(@pdf.font_families.include?(:MSJH))
  end
end
