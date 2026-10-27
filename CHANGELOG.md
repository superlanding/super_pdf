# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `CHANGELOG.md`.
- README: what the gem is, requirements, installation, usage examples, development and release instructions.
- CLAUDE.md: every PR must also update `README.md` and `CHANGELOG.md`.

## [0.1.6] - 2026-10-27

### Fixed

- `div`, `row` and `row.column` raised `ArgumentError (wrong number of arguments (given 2, expected 1))` on Ruby 3.x, because `div` passed a Hash to the keyword-argument methods `margin_div` / `padding_div`. The options are now splatted (`**`), so they work on Ruby 3.0–3.4 and keep working with every existing call style (`div(margin: 10)`, `div({ margin: 10 })`, `row.column(width: "50%")`). The public API is unchanged.
- `row.column(options)` no longer deletes `:width` from the Hash passed in by the caller (it works on a copy).

### Added

- Tests for `div` (keyword / hash options, border, background colour, percentage width, no mutation of the options) and for `row` / `column`.

## [0.1.5] - 2026-10-27

### Added

- GitHub Actions test workflow: Ruby 3.0–3.4 × Rails (ActiveSupport) 7.0–8.1 matrix.
- GitHub Actions workflow `publish.yml`: publishes to RubyGems automatically (Trusted Publishing) when a new version lands on `master`.
- CLAUDE.md with the release / version-bump rules.

### Changed

- Support ActiveSupport 8 and Ruby 3.3–3.4: gemspec declares `required_ruby_version >= 2.7` and depends on `matrix` and `ostruct` (no longer default gems on newer Rubies); explicit ActiveSupport `Concern` / `delegation` requires; `draw_border` keyword arguments are splatted.
- Gemfiles per ActiveSupport version (`gemfiles/rails_7.0.gemfile` … `rails_8.1.gemfile`).

## [0.1.4] - 2019-10-18

### Added

- `SuperPDF.extension_add(base)` and `SuperPDF.extensions` to register `Prawn::Document` extensions.

### Fixed

- Loosen the `activesupport` requirement (`>= 4`).

## [0.1.2] - 2019-09-17

### Changed

- Dynamic document: `SuperPDF::Enhance#pdf` now builds an anonymous `Prawn::Document` subclass (with `SuperPDF::Renderer` mixed in) instead of using the static `SuperPDF::Document` class, which was removed.

## [0.1.1] - 2019-09-17

### Added

- `prawn-icon` runtime dependency.

## [0.1.0] - 2019-09-02

### Added

- Initial release: `SuperPDF::Enhance`, `SuperPDF::Page` (page sizes), `SuperPDF::Font` (default font families) and `SuperPDF::Renderer` (`page`, `margin_div`, `padding_div`, `abs_div`, `row`/`column`, `scale`, borders and background colours) on top of Prawn.

[Unreleased]: https://github.com/superlanding/super_pdf/compare/v0.1.6...HEAD
[0.1.6]: https://github.com/superlanding/super_pdf/compare/v0.1.5...v0.1.6
[0.1.5]: https://github.com/superlanding/super_pdf/compare/v0.1.4...v0.1.5
[0.1.4]: https://github.com/superlanding/super_pdf/tree/v0.1.4
[0.1.2]: https://github.com/superlanding/super_pdf/tree/0.1.2
[0.1.1]: https://github.com/superlanding/super_pdf/tree/0.1.1
[0.1.0]: https://github.com/superlanding/super_pdf/commit/e85890b
