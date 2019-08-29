require 'super_pdf/renderer/helper'
require 'super_pdf/renderer/rows'

module SuperPDF
  module Renderer
    extend ActiveSupport::Concern
    include Renderer::Helper

    included do

      # 開新的一頁
      # Examples:
      #   page(size: "A4", layout: :landscape)
      #   page(left_margin: 50, right_margin: 50)
      #   page(margin: 100)
      #   page(font: 'MJSH')
      #
      def page(options={})
        family = options.delete(:font) || default_font_family
        options[:size] = Page.real_size(options[:size])
        start_new_page(options)
        with_font(family) do
          yield if block_given?
        end
      end

      # 文字
      #
      # Examples
      #   text("...", size: 8, align: :center, valign: :center) do
      #     ...
      #   end
      def text(string, options={})
        family = options.delete(:family)
        with_font(family) do
          super(string, options)
        end
      end

      # 區塊
      # Options:
      #   options[:margin]
      #   options[:padding]
      #   options[:width]
      #   options[:height]
      #   options[:background_color]
      #
      # Examples:
      #   div(margin: [20, 30], padding: 10, border: true) do
      #     ...
      #   end
      #   div(margin: [20, 30], width: '50%', border: true) do
      #     ...
      #   end
      def div(options = {}, &block)
        margin_div(options[:margin], options.slice(:width, :height, :border, :background_color)) do
          padding_div(options[:padding], options.slice(:width, :height), &block)
        end
      end

      # Examples:
      #
      # Margin + width
      # margin_div(20, width: 100, height: 100, border: true) do
      #   ...
      # end
      #
      # Auto width:
      # margin_div([10, 20]) do
      #   ....
      # end
      #
      def margin_div(margin, width: nil, height: nil, border: false, background_color: nil, &block)
        margin = convert_margin(margin)

        # 上一個 Element 的寬度, 要讓他擠下來
        pre_height = bounds.height - cursor

        # 外寬
        width = percent2pt_of_width(width) if percentage?(width)
        width ||= (bounds.width - margin.left - margin.right)
        width += (margin.left + margin.right)

        # 外高
        height = percent2pt_of_height(height) if percentage?(height)
        height ||= bounds.height - margin.top - margin.bottom - pre_height
        height += (margin.top + margin.bottom)

        # 外框
        bounding_box([bounds.left, bounds.top - pre_height], width: width, height: height) do
          left  = bounds.left + margin.left
          top   = bounds.top - margin.top
          width   = bounds.width - margin.left - margin.right
          height  = bounds.height - margin.top - margin.bottom
          # 內框
          bounding_box([left, top], width: width, height: height) do
            yield if block_given?
            fill_background_color(background_color) if background_color
            draw_border(convert_border_options(border)) if border
          end
        end
      end

      # Examples:
      #
      # padding_div(20, width: 100, height: 100, border: true) do
      #   ...
      # end
      #
      # Auto width:
      # padding_div([10, 20, 10, 10]) do
      #   ...
      # end
      #
      def padding_div(padding, width: nil, height: nil, border: false, background_color: false, &block)
        padding = convert_margin(padding)

        pre_height = bounds.height - cursor

        width = percent2pt_of_width(width) if percentage?(width)
        width ||= bounds.width

        height = percent2pt_of_height(height) if percentage?(height)
        height ||= bounds.height - pre_height

        bounding_box([bounds.left, bounds.top - pre_height], width: width, height: height) do
          draw_border(convert_border_options(border)) if border
          fill_background_color(background_color) if background_color

          left  = bounds.left + padding.left
          top   = bounds.top - padding.top
          width   = bounds.width - padding.left - padding.right
          height  = bounds.height - padding.top - padding.bottom
          bounding_box([left, top], width: width, height: height) do
            yield if block_given?
          end
        end
      end

      # Examples:
      #
      # abs_div(left: 10, top: 10) do
      #   ...
      # end
      #
      # abs_div(left: '10%', top: '10%') do
      #   ...
      # end
      #
      # abs_div(left: 10, top: 10, right: 20, bottom: 20) do
      #   ...
      # end
      #
      # abs_div(border: true, background_color: '#222') do
      #   ...
      # end
      #
      def abs_div(left: 0, right: 0, top: 0, bottom: 0, border: false, background_color: false, &block)
        left  = percent2pt_of_width(left) if percentage?(left)
        right = percent2pt_of_width(right) if percentage?(right)
        top     = percent2pt_of_height(top) if percentage?(top)
        bottom  = percent2pt_of_height(bottom) if percentage?(bottom)

        width   = bounds.width - left - right
        height  = bounds.height - top - bottom

        cursor_cache = cursor

        bounding_box([
          bounds.left + left, bounds.top - top
        ], width: width, height: height) do
          fill_background_color(background_color) if background_color
          draw_border(convert_border_options(border)) if border
          yield if block_given?
        end
        move_cursor_to cursor_cache
      end

      # 似 bootstrap4 grid
      #
      # div(options) do
      #   row do |row|
      #     row.column(width: '50%', ...) do
      #       ...
      #     end
      #     row.column(width: '50%', ...) do
      #       ...
      #     end
      #   end
      # end
      #
      def row(&block)
        div do
          rows.row(&block)
        end
      end

      # 縮放
      #
      # Params
      #   factor 縮放比例
      #   options[:origin] 縮放起始點
      #   options[:position] :center
      #
      # Examples
      #   scale(0.8) do
      #     ...
      #   end
      #
      #   scale(0.8, origin: [0, 100]) do
      #     ...
      #   end
      #
      #   scale(0.8, position: :center) do
      #     ...
      #   end
      #
      def scale(factor, options={}, &block)
        position = options.delete(:position)
        case position
        when :center
          options[:origin] ||= [
            bounds.left + (bounds.width / 2),
            cursor - (bounds.height / 2)
          ]
        else
          options[:origin] ||= [ bounds.left, cursor ]
        end
        super(factor, options, &block)
      end

      # 填充背景顏色
      #
      # Examples:
      #   fill_background_color('#f0ffc1')
      #
      def fill_background_color(code)
        code = full_color_code(code)
        fill_color(code)
        fill_rectangle([bounds.left, bounds.top], bounds.width, bounds.height)
      end

      # 旋轉
      # def rotate(angle, options={}, &block)
      #   super(angle, options={}, &block)
      # end

      # 複寫 Prawn::Document，讓其可以吃預設字體
      # def font(name=nil, options={}, &block)
      #   font_family = (name || default_font_family)
      #   super(font_family, options, &block)
      # end

      # 頁面寬
      def page_width
        margin_box.width
      end

      # 頁面高
      def page_height
        margin_box.height
      end

      def draw_border(color:, style:, width:)
        line_width(width)
        stroke_color(color)
        case style
        when "dotted"
          dash(1, space: 1)
        when "dashed"
          dash(4, space: 2)
        when "solid"
          # Do nothing.
        else
          raise 'Style only for "dotted", "dashed", "solid"'
        end
        stroke_bounds
        undash
      end

      protected

      def rows
        @rows ||= Rows.new(self)
      end

      def with_font(family, &block)
        if family
          font(family, &block)
        else
          block.call
        end
      end
    end
  end
end
