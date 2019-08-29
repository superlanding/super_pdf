require 'test_helper'

class RendererTest < Minitest::Test

  def pdf
    @pdf ||= Class.new do
      include SuperPDF::Enhance
    end.new.pdf
  end

  def test_page
    pdf.page
    assert_equal(1, pdf.page_count)
  end

  def test_page_with_margin
    pdf.page(margin: 10)
    assert_equal({left: 10, right: 10, top: 10, bottom: 10}, pdf.state.page.margins)
  end

  def test_page_with_font
    pdf.page(font: 'Times-Roman') do
      assert_equal('Times-Roman', pdf.font.family)
    end
  end

  def test_text_with_font_family
    pdf.page
    pdf.expects(:with_font).with('Times-Roman').once
    pdf.text 'Test', family: 'Times-Roman'
  end

  def test_page_width
    assert_equal(595.28, pdf.page_width)
  end

  def test_page_height
    assert_equal(841.89, pdf.page_height)
  end

  def test_font
    pdf.stubs(:default_font_family).returns('Times-Roman')
    pdf.page
    pdf.font do
      assert_equal('Times-Roman', pdf.font.family)
    end
  end

  def test_margin_div
    pdf.page do
      pdf.margin_div([20, 10], height: 100) do
        assert_equal(20, pdf.page_width - pdf.bounds.width)
        assert_equal(100, pdf.bounds.height)
      end
      assert_equal(100 + 20 + 20, pdf.page_height - pdf.cursor)
      pdf.margin_div(0) do
        assert_equal(100 + 20 + 20, pdf.page_height - pdf.bounds.top)
      end
    end
  end

  def test_margin_div_with_border
    pdf.page
    pdf.margin_div(10, width: 100, height: 100, border: '0.5pt solid #222') do
      pdf.expects(:stroke_bounds).once
    end
    assert_equal('222222', pdf.graphic_state.stroke_color)
    assert_equal(0.5, pdf.graphic_state.line_width)
  end

  def test_margin_div_with_bg_color
    pdf.page
    pdf.margin_div(10, width: 100, height: 100, background_color: '#222') do
      pdf.expects(:fill_rectangle).with([pdf.bounds.left, pdf.bounds.top], pdf.bounds.width, pdf.bounds.height).once
    end
    assert_equal('222222', pdf.graphic_state.fill_color)
  end

  def test_padding_div
    pdf.page do
      pdf.padding_div([20, 10], width: 100, height: 100) do
        assert_equal(100 - 20, pdf.bounds.width)
        assert_equal(100 - 40, pdf.bounds.height)
      end
      assert_equal(100, pdf.page_height - pdf.cursor)
      pdf.padding_div(0) do
        assert_equal(100, pdf.page_height - pdf.bounds.top)
        assert_equal(pdf.page_height - 100, pdf.bounds.height)
      end
    end
  end

  def test_row
    # TODO: ...
  end

  def test_scale
    # TODO: ...
  end

  def test_abs_div
    pdf.page do
      pdf.margin_div(0, width: 100, height: 100) do
        pdf.abs_div(top: 20, bottom: 10, left: 30, right: 40) do
          assert_equal(70, pdf.bounds.height)
          assert_equal(30, pdf.bounds.width)
        end
      end
    end
  end

  def test_draw_border
    pdf.expects(:stroke_bounds).once
    pdf.expects(:dash).once
    pdf.expects(:undash).once
    pdf.draw_border(width: 1, style: 'dashed', color: '222222')
    assert_equal('222222', pdf.graphic_state.stroke_color)
    assert_equal(1, pdf.graphic_state.line_width)
  end
end
