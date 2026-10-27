# SuperPDF

[![Gem Version](https://badge.fury.io/rb/super_pdf.svg)](https://rubygems.org/gems/super_pdf)
[![Tests](https://github.com/superlanding/super_pdf/actions/workflows/test.yml/badge.svg)](https://github.com/superlanding/super_pdf/actions/workflows/test.yml)

SuperPDF is a small layout layer on top of [Prawn](https://prawnpdf.org/). Include
`SuperPDF::Enhance` in any plain Ruby class and you get a `pdf` object (a `Prawn::Document`)
with CSS-like helpers: boxes with margin / padding / border / background colour,
absolutely positioned blocks, a default font and named page sizes.

It only depends on `activesupport` (not on a full Rails app), so it can be used from Rails,
Sidekiq jobs, scripts, and so on.

## Requirements

| | Supported (tested in CI) |
|---|---|
| Ruby | 3.0, 3.1, 3.2, 3.3, 3.4 (gemspec: `>= 2.7`) |
| ActiveSupport / Rails | 7.0, 7.1, 7.2, 8.0, 8.1 (gemspec: `activesupport >= 4`) |
| Runtime dependencies | `prawn ~> 2.2`, `prawn-table 0.2.2`, `prawn-icon 2.4.0`, `matrix`, `ostruct` |

CI runs every Ruby × ActiveSupport combination that the Ruby version allows
(Rails 7.2 needs Ruby >= 3.1, Rails 8.0 / 8.1 need Ruby >= 3.2).
See [`.github/workflows/test.yml`](.github/workflows/test.yml).

## Installation

Add this line to your application's Gemfile:

```ruby
gem "super_pdf"
```

and run `bundle install`, or install it yourself with `gem install super_pdf`.

## Usage

### 1. Register fonts and page sizes (once, e.g. in an initializer)

```ruby
require "super_pdf"

# Page sizes: name => [width, height] in PDF points (1 pt = 1/72 in), or any value
# that Prawn accepts for :page_size, such as "A4". "A4" is the default.
SuperPDF::Page::SIZE["label_100x150"] = [283.46, 425.2]

# Fonts: use String keys. The value is a Prawn font family hash.
SuperPDF::Font::FAMILIES["NotoSansTC"] = {
  normal: Rails.root.join("app/assets/fonts/NotoSansTC-Regular.ttf").to_s,
  bold:   Rails.root.join("app/assets/fonts/NotoSansTC-Bold.ttf").to_s
}
```

### 2. Include `SuperPDF::Enhance` in your class

```ruby
class ShippingLabelPDF
  include SuperPDF::Enhance

  page_size "label_100x150"      # a key of SuperPDF::Page::SIZE (default: "A4")
  default_font "NotoSansTC"      # a key of SuperPDF::Font::FAMILIES

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

    pdf.render   # => PDF binary string; use pdf.render_file("label.pdf") to write a file
  end
end

File.binwrite("label.pdf", ShippingLabelPDF.new.render)
```

`pdf` is memoised per instance and is created with `skip_page_creation: true` and zero
margin, so always start with `pdf.page`.

### Helpers added to `pdf`

| Method | What it does |
|---|---|
| `page(options = {}) { }` | Starts a new page (`size:`, `layout:`, `margin:`, `font:` …) and runs the block with the default font. `size:` is looked up in `SuperPDF::Page::SIZE`. |
| `text(string, family: "Name", **prawn_options)` | `Prawn::Document#text` with an optional font `family:` for that call. |
| `margin_div(margin, width:, height:, border:, background_color:) { }` | Box with an outer margin. Width / height accept points or `"50%"` strings. |
| `padding_div(padding, width:, height:, border:, background_color:) { }` | Box with inner padding. |
| `div(margin:, padding:, width:, height:, border:, background_color:) { }` | `margin_div` and `padding_div` in one call (options as keywords or a Hash). |
| `row { \|row\| row.column(width: "50%", **div_options) { } }` | Bootstrap-like grid: columns are laid out left to right inside the row. |
| `abs_div(left:, right:, top:, bottom:, border:, background_color:) { }` | Absolutely positioned block inside the current bounds (numbers or `"10%"`); the cursor is restored afterwards. |
| `scale(factor, origin: [x, y], position: :center) { }` | Scales the content of the block. |
| `fill_background_color("#f0ffc1")` | Fills the current bounds (`#rgb` or `#rrggbb`). |
| `page_width`, `page_height` | Size of the margin box. |

Margin / padding values follow CSS shorthand: `10`, `[vertical, horizontal]`, `[top, horizontal, bottom]`
or `[top, right, bottom, left]`.

Border values are `true` (1 pt solid black), a string such as `"1pt dashed #222"`
(`<width><mm|cm|dm|m|in|yd|ft|pt> <solid|dashed|dotted> #<rgb|rrggbb>`), or a hash
`{ color: "222222", style: "solid", width: 1 }`.

### Extending Prawn

```ruby
SuperPDF.extension_add(MyPrawnExtension)  # same as Prawn::Document.extensions << MyPrawnExtension
SuperPDF.extensions                        # => Prawn::Document.extensions
```

### Known limitations

These come from the current implementation and are documented here so that you do not trip over them:

- `div(width: "50%")` applies the percentage twice (to the margin box, then to the padding box inside it), so the content is 25 % wide.
  Behaviour kept for compatibility; use `margin_div` / `padding_div` for exact percentages, or a numeric width.
- Font family names are looked up as Strings by current Prawn versions, so register and select fonts with **String** names
  (`"NotoSansTC"`, not `:NotoSansTC`).
- `test/support/font/MSJH.ttf` in this repository is an empty placeholder; tests do not render with a real font.

## Development

```bash
git clone https://github.com/superlanding/super_pdf.git
cd super_pdf
bin/setup                       # bundle install with the default Gemfile

# Run the tests against one Ruby / Rails combination (the same way CI does)
BUNDLE_GEMFILE=$PWD/gemfiles/rails_8.1.gemfile bundle install
BUNDLE_GEMFILE=$PWD/gemfiles/rails_8.1.gemfile bundle exec rake test

bin/console                     # interactive prompt
```

Available gemfiles: `gemfiles/rails_7.0.gemfile` … `gemfiles/rails_8.1.gemfile`. Tests use Minitest and Mocha
(`test/**/*_test.rb`). `rake` (default task) runs the tests.

## Releasing

Releases are automated with RubyGems [Trusted Publishing](https://guides.rubygems.org/trusted-publishing/)
(no API key is stored in the repository):

1. In your pull request, bump `SuperPDF::VERSION` in `lib/super_pdf/version.rb` following
   [Semantic Versioning](https://semver.org/) (bug fix → patch, compatible feature → minor, breaking change → major).
2. Add the entry to `CHANGELOG.md` under the new version section.
3. Get the PR reviewed and **merge it into `master`** (only humans merge).
4. [`.github/workflows/publish.yml`](.github/workflows/publish.yml) runs on `master`: it compares the gemspec version with
   rubygems.org, runs the tests and, if the version is new, publishes the gem and pushes the `vX.Y.Z` tag.
   A merge that does not change the version publishes nothing.

Pull requests that only change documentation or CI do not need a version bump. See [CLAUDE.md](CLAUDE.md)
for the contribution rules (every PR must also update `README.md` and `CHANGELOG.md`).

## Contributing

Bug reports and pull requests are welcome at https://github.com/superlanding/super_pdf.

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.txt).
