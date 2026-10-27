# SuperPDF

[![Gem Version](https://badge.fury.io/rb/super_pdf.svg)](https://rubygems.org/gems/super_pdf)
[![Tests](https://github.com/superlanding/super_pdf/actions/workflows/test.yml/badge.svg)](https://github.com/superlanding/super_pdf/actions/workflows/test.yml)

SuperPDF 是建構在 [Prawn](https://prawnpdf.org/) 之上的一層簡易排版工具。在任何一般的 Ruby class 裡 include
`SuperPDF::Enhance`，就會得到一個 `pdf` 物件（也就是 `Prawn::Document`），並附帶類似 CSS 的輔助方法：
可設定 margin / padding / border / 背景色的區塊、絕對定位區塊、預設字型，以及具名的頁面尺寸。

它只依賴 `activesupport`（不需要完整的 Rails 應用程式），所以 Rails、Sidekiq job、一般腳本等環境都能使用。

## 環境需求

| | 支援版本（CI 都有測試） |
|---|---|
| Ruby | 3.0、3.1、3.2、3.3、3.4（gemspec：`>= 2.7`） |
| ActiveSupport / Rails | 7.0、7.1、7.2、8.0、8.1（gemspec：`activesupport >= 4`） |
| Runtime 相依套件 | `prawn ~> 2.2`、`prawn-table 0.2.2`、`prawn-icon 2.4.0`、`matrix`、`ostruct` |

CI 會跑所有該 Ruby 版本允許的 Ruby × ActiveSupport 組合
（Rails 7.2 需要 Ruby >= 3.1，Rails 8.0 / 8.1 需要 Ruby >= 3.2）。
詳見 [`.github/workflows/test.yml`](.github/workflows/test.yml)。

## 安裝

在應用程式的 Gemfile 加入這一行：

```ruby
gem "super_pdf"
```

然後執行 `bundle install`，或自行執行 `gem install super_pdf` 安裝。

## 使用方式

### 1. 註冊字型與頁面尺寸（只需做一次，例如放在 initializer）

```ruby
require "super_pdf"

# 頁面尺寸：名稱 => [寬, 高]，單位為 PDF point（1 pt = 1/72 英吋），
# 也可以是 Prawn 的 :page_size 接受的任何值，例如 "A4"。預設為 "A4"。
SuperPDF::Page::SIZE["label_100x150"] = [283.46, 425.2]

# 字型：key 請用 String，value 是 Prawn 的 font family hash。
SuperPDF::Font::FAMILIES["NotoSansTC"] = {
  normal: Rails.root.join("app/assets/fonts/NotoSansTC-Regular.ttf").to_s,
  bold:   Rails.root.join("app/assets/fonts/NotoSansTC-Bold.ttf").to_s
}
```

### 2. 在你的 class 裡 include `SuperPDF::Enhance`

```ruby
class ShippingLabelPDF
  include SuperPDF::Enhance

  page_size "label_100x150"      # SuperPDF::Page::SIZE 的 key（預設："A4"）
  default_font "NotoSansTC"      # SuperPDF::Font::FAMILIES 的 key

  def render
    pdf.page(margin: 10) do
      pdf.margin_div([0, 0, 10, 0], height: 40, border: "1pt solid #222") do
        pdf.text "Shipping label", size: 14, align: :center
      end

      pdf.padding_div(5, width: 200, height: 60, border: true) do
        pdf.text "Padded box"
      end

      pdf.abs_div(left: 10, top: 150, right: 10, bottom: 10, background_color: "#f0ffc1") do
        pdf.text "Absolutely positioned", size: 8
      end

      pdf.scale(0.8, position: :center) { pdf.text "Scaled" }
    end

    pdf.render   # => PDF 二進位字串；要寫成檔案請用 pdf.render_file("label.pdf")
  end
end

File.binwrite("label.pdf", ShippingLabelPDF.new.render)
```

`pdf` 在每個 instance 內只會建立一次（memoize），建立時帶有 `skip_page_creation: true` 且 margin 為 0，
所以一律要從 `pdf.page` 開始。

### `pdf` 提供的輔助方法

| 方法 | 說明 |
|---|---|
| `page(options = {}) { }` | 開新的一頁（可帶 `size:`、`layout:`、`margin:`、`font:` 等），並以預設字型執行 block。`size:` 會到 `SuperPDF::Page::SIZE` 查詢。 |
| `text(string, family: "Name", **prawn_options)` | 即 `Prawn::Document#text`，可用 `family:` 指定這次呼叫使用的字型。 |
| `margin_div(margin, width:, height:, border:, background_color:) { }` | 帶外距（margin）的區塊。寬 / 高可傳 point 數值或 `"50%"` 字串。 |
| `padding_div(padding, width:, height:, border:, background_color:) { }` | 帶內距（padding）的區塊。 |
| `div(margin:, padding:, width:, height:, border:, background_color:) { }` | 一次呼叫就同時具備 `margin_div` 與 `padding_div`（options 可用 keyword 或 Hash 傳入）。 |
| `row { \|row\| row.column(width: "50%", **div_options) { } }` | 類似 Bootstrap 的 grid：欄（column）在 row 內由左到右排列。 |
| `abs_div(left:, right:, top:, bottom:, border:, background_color:) { }` | 在目前的 bounds 內做絕對定位的區塊（數值或 `"10%"`）；結束後會還原游標位置。 |
| `scale(factor, origin: [x, y], position: :center) { }` | 縮放 block 內的內容。 |
| `fill_background_color("#f0ffc1")` | 以背景色填滿目前的 bounds（`#rgb` 或 `#rrggbb`）。 |
| `page_width`、`page_height` | 扣除 margin 之後的可用區域大小。 |

margin / padding 的值沿用 CSS 簡寫規則：`10`、`[vertical, horizontal]`、`[top, horizontal, bottom]`
或 `[top, right, bottom, left]`。

border 的值可以是 `true`（1 pt 實線、黑色）、像 `"1pt dashed #222"` 這樣的字串
（`<width><mm|cm|dm|m|in|yd|ft|pt> <solid|dashed|dotted> #<rgb|rrggbb>`），或是 hash
`{ color: "222222", style: "solid", width: 1 }`。

### 擴充 Prawn

```ruby
SuperPDF.extension_add(MyPrawnExtension)  # 等同於 Prawn::Document.extensions << MyPrawnExtension
SuperPDF.extensions                        # => Prawn::Document.extensions
```

### 已知限制

以下是目前實作造成的限制，先寫在這裡，避免你踩到：

- `div(width: "50%")` 會把百分比套用兩次（先套在 margin 區塊，再套在裡面的 padding 區塊），所以內容實際只有 25 % 寬。
  為了相容性保留這個行為；要精確的百分比請改用 `margin_div` / `padding_div`，或使用數值寬度。
- 目前版本的 Prawn 是以 String 查詢字型 family 名稱，所以註冊與選用字型時請用 **String** 名稱
  （`"NotoSansTC"`，不要用 `:NotoSansTC`）。
- 此 repo 內的 `test/support/font/MSJH.ttf` 是空的佔位檔；測試不會用真正的字型來 render。

## 開發

```bash
git clone https://github.com/superlanding/super_pdf.git
cd super_pdf
bin/setup                       # 用預設 Gemfile 執行 bundle install

# 針對單一 Ruby / Rails 組合跑測試（和 CI 的做法相同）
BUNDLE_GEMFILE=$PWD/gemfiles/rails_8.1.gemfile bundle install
BUNDLE_GEMFILE=$PWD/gemfiles/rails_8.1.gemfile bundle exec rake test

bin/console                     # 互動式 console
```

可用的 gemfile：`gemfiles/rails_7.0.gemfile` … `gemfiles/rails_8.1.gemfile`。測試使用 Minitest 與 Mocha
（`test/**/*_test.rb`）。`rake`（預設 task）會執行測試。

## 發版

發版透過 RubyGems [Trusted Publishing](https://guides.rubygems.org/trusted-publishing/) 自動完成
（repo 內不存放任何 API key）：

1. 在你的 pull request 裡，依 [Semantic Versioning](https://semver.org/lang/zh-TW/) 修改 `lib/super_pdf/version.rb` 的
   `SuperPDF::VERSION`（修 bug → patch、相容的新功能 → minor、不相容的變更 → major）。
2. 在 `CHANGELOG.md` 的新版本區塊新增對應條目。
3. PR 經過 review 後**合併進 `master`**（只有真人可以合併）。
4. [`.github/workflows/publish.yml`](.github/workflows/publish.yml) 會在 `master` 上執行：比對 gemspec 版本與
   rubygems.org 上的版本，執行測試，若是新版本就發佈 gem 並推送 `vX.Y.Z` tag。
   沒有改版本號的合併不會發佈任何東西。

只改文件或 CI 的 pull request 不需要跳版號。貢獻規則請見 [CLAUDE.md](CLAUDE.md)
（每個 PR 也都必須更新 `README.md` 與 `CHANGELOG.md`）。

## 貢獻

歡迎到 https://github.com/superlanding/super_pdf 回報問題與提交 pull request。

## 授權

本 gem 以 [MIT License](LICENSE.txt) 條款開源。
