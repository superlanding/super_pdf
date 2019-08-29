require 'test_helper'

class PageTest < Minitest::Test

  class FakePDF
    include SuperPDF::Page
  end

  def test_size_default
    assert_equal('A4', FakePDF.new.page_size)
  end

  SuperPDF::Page::SIZE['10x10'] = [283, 283]
  class FakePDFWithSize
    include SuperPDF::Page

    page_size '10x10'
  end

  def test_size_customize
    assert_equal([283, 283], FakePDFWithSize.new.page_size)
  end
end
