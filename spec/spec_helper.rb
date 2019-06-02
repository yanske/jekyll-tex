$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "jekyll"
require "jekyll-tex"
require 'byebug'

RSpec.configure do |config|
  SOURCE_DIR = File.expand_path("fixtures", __dir__)
  DEST_DIR   = File.expand_path("../spec_build", __dir__)

  def source_dir(*files)
    File.join(SOURCE_DIR, *files)
  end

  def dest_dir(*files)
    File.join(DEST_DIR, *files)
  end

  def clean_file(file)
    File.delete(file) if File.exists?(file)
  end
end
