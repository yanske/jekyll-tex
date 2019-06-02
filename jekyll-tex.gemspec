lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "jekyll-tex/version"

Gem::Specification.new do |spec|
  spec.name = "jekyll-tex"
  spec.summary = "Build tex files for PDF assets."
  spec.version = Jekyll::Tex::VERSION
  spec.files = Dir.glob("lib/*")
  spec.authors = ["Yan Ke"]

  spec.add_dependency "jekyll", ">= 3.7", "< 5"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "byebug", "~> 11.0"
end
