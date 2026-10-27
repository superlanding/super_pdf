# 更新紀錄（Changelog）

本檔記錄此專案所有值得注意的變更。

格式參考 [Keep a Changelog](https://keepachangelog.com/zh-TW/1.1.0/)，版本號遵循 [Semantic Versioning](https://semver.org/lang/zh-TW/)。

## [Unreleased]

### Added

- 新增 `CHANGELOG.md`。
- README：說明這個 gem 是什麼、環境需求、安裝、使用範例、開發與發版方式。
- CLAUDE.md：每個 PR 都必須同步更新 `README.md` 與 `CHANGELOG.md`；`README.md` 與 `CHANGELOG.md` 一律用繁體中文撰寫。

### Changed

- `README.md`、`CHANGELOG.md` 改以繁體中文（zh-TW）撰寫。

## [0.1.5] - 2026-10-27

### Added

- GitHub Actions 測試 workflow：Ruby 3.0–3.4 × Rails（ActiveSupport）7.0–8.1 矩陣。
- GitHub Actions workflow `publish.yml`：新版本進到 `master` 時自動發佈到 RubyGems（Trusted Publishing）。
- CLAUDE.md：加入發版 / 跳版號規則。

### Changed

- 支援 ActiveSupport 8 與 Ruby 3.3–3.4：gemspec 宣告 `required_ruby_version >= 2.7`，並相依 `matrix` 與 `ostruct`（在較新的 Ruby 已不再是 default gem）；明確 require ActiveSupport 的 `Concern` / `delegation`；`draw_border` 的 keyword arguments 改用 splat 傳遞。
- 依 ActiveSupport 版本拆分 Gemfile（`gemfiles/rails_7.0.gemfile` … `rails_8.1.gemfile`）。

## [0.1.4] - 2019-10-18

### Added

- 新增 `SuperPDF.extension_add(base)` 與 `SuperPDF.extensions`，用來註冊 `Prawn::Document` 的擴充。

### Fixed

- 放寬 `activesupport` 的版本限制（`>= 4`）。

## [0.1.2] - 2019-09-17

### Changed

- 動態 document：`SuperPDF::Enhance#pdf` 現在會建立一個匿名的 `Prawn::Document` 子類別（並 mix in `SuperPDF::Renderer`），不再使用靜態的 `SuperPDF::Document` class（該 class 已移除）。

## [0.1.1] - 2019-09-17

### Added

- 新增 runtime 相依套件 `prawn-icon`。

## [0.1.0] - 2019-09-02

### Added

- 首次發佈：在 Prawn 之上提供 `SuperPDF::Enhance`、`SuperPDF::Page`（頁面尺寸）、`SuperPDF::Font`（預設字型 family）與 `SuperPDF::Renderer`（`page`、`margin_div`、`padding_div`、`abs_div`、`row`/`column`、`scale`、邊框與背景色）。

[Unreleased]: https://github.com/superlanding/super_pdf/compare/v0.1.5...HEAD
[0.1.5]: https://github.com/superlanding/super_pdf/compare/v0.1.4...v0.1.5
[0.1.4]: https://github.com/superlanding/super_pdf/tree/v0.1.4
[0.1.2]: https://github.com/superlanding/super_pdf/tree/0.1.2
[0.1.1]: https://github.com/superlanding/super_pdf/tree/0.1.1
[0.1.0]: https://github.com/superlanding/super_pdf/commit/e85890b
