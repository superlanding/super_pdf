require 'test_helper'

class RendererHelperTest < Minitest::Test

  def test_convert_border_options
    cases = {
      true => { color: '000000', style: 'solid', width: 1 },
      '1pt dashed #222' => { color: '222222', style: 'dashed', width: 1 },
      '1mm dashed #222' => { color: '222222', style: 'dashed', width: 2.834645669291339 }
    }

    assert_nil(helper.convert_border_options(false))
    cases.each do |option, expected|
      assert_equal(expected, helper.convert_border_options(option))
    end
  end

  def test_convert_border_options_if_wrong_input
    assert_raises(ArgumentError) { helper.convert_border_options("1xx dashed #222") }
    assert_raises(ArgumentError) { helper.convert_border_options("xxxx") }
  end

  protected

  def helper
    @helper ||= Class.new do
      include SuperPDF::Renderer::Helper
    end.new
  end
end
