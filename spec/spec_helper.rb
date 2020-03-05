# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'jekyll'
require 'jekyll-tex'
require 'byebug'

RSpec.configure do |_config|
  SOURCE_DIR = File.expand_path('fixtures', __dir__)
  DEST_DIR = File.expand_path('../spec_build', __dir__)

  def source_dir(*files)
    File.join(SOURCE_DIR, *files)
  end

  def dest_dir(*files)
    File.join(DEST_DIR, *files)
  end

  def clean_file(file)
    File.delete(file) if File.exist?(file)
  end

  def stub_updated_pdf(file)
    # Stub and say that we do have the pdf.
    allow(File).to receive(:exist?)
    expect(File).to receive(:exist?).with(source_dir(file)).and_return(true)

    # Let all files have the same last modified time.
    allow(File).to receive(:mtime).and_return(1)
  end
end
