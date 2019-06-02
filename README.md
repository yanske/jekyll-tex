# Jekyll Tex

Jekyll plugin to build PDF files from your Latex files.

## Dependencies

Use of this Gem requires `pdflatex`.

## Usage

1. Add this Gem to your Gemfile.
```
gem 'jekyll-tex', git: 'https://github.com/yanske1/jekyll-tex'
```

2. In `_config`, add `jekyll-tex` under `plugins`.
```
plugins:
  - jekyll-tex
```

3. Configure a source path & output path for your PDF files:

```
tex:
  source: assets/tex
  output: assets
```
