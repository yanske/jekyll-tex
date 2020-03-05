# frozen_string_literal: true

require 'fileutils'
require_relative 'compiler.rb'

module Jekyll
  module Tex
    class Builder < Jekyll::Generator
      safe true

      def generate(site)
        @site = site

        Dir.glob(File.join(@site.source, config[:source]) + '/*.tex') do |path|
          tex = File.basename(path)

          next unless update_pdf?(tex)

          # Compile, and if successful (i.e. the compiler doesn't raise
          # an error), it'll register it as a static file in the site.
          target_dir = File.join(@site.source, config[:output])
          Jekyll::Tex::Compiler.compile(source_path(tex), target_dir, options: config[:options])

          pdf = File.basename(tex, '.tex') + '.pdf'
          @site.static_files << StaticFile.new(@site, @site.source, config[:output], pdf)
        end
      end

      private

      CONFIG_KEY = 'tex'

      DEFAULT_CONFIG = {
        options: [],
        source: 'assets/tex',
        output: 'assets'
      }.freeze

      def config
        @config ||= begin
          site_config = @site.config[CONFIG_KEY] || {}
          DEFAULT_CONFIG.merge(site_config.transform_keys(&:to_sym))
        end
      end

      def source_path(tex)
        File.join(@site.source, config[:source], tex)
      end

      def target_path(tex)
        pdf_file = File.basename(tex, '.tex') + '.pdf'
        File.join(@site.source, config[:output], pdf_file)
      end

      def update_pdf?(tex)
        return true unless File.exist?(target_path(tex))

        # Check if the file is up-to-date compared to the tex file. We
        # want to update if the PDF file is not as recently modified.
        File.mtime(target_path(tex)) < File.mtime(source_path(tex))
      end
    end
  end
end
