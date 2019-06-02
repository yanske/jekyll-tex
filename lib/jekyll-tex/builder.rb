require "fileutils"

module Jekyll
  module Tex
    class Builder < Jekyll::Generator
      safe true
  
      def generate(site)
        @site = site

        Dir.glob(File.join(@site.source, config[:source]) + '/*.tex') do |path|
          tex = File.basename(path)

          next unless update_pdf?(tex)

          build(tex)
          cleanup(tex)
        end
      end

      private

      CONFIG_KEY = "tex".freeze

      DEFAULT_CONFIG = {
        builder: 'pdflatex',
        options: ['--interaction=batchmode'],
        source:  'assets/tex',
        output:  'assets',
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

      def build(tex)
        system config[:builder], *config[:options], source_path(tex)

        pdf_file = File.basename(tex, '.tex') + '.pdf'

        # The builder outputs the PDF file in the top level directory of the site. We need to
        # move it to the source directory, and add it to the site's inventory.
        unless $?.exitstatus.zero? && File.exist?(pdf_file)
          raise "Build status 0 or file does not exist!"
        end

        FileUtils.move pdf_file, target_path(tex)
        @site.static_files << StaticFile.new(@site, @site.source, config[:output], pdf_file)
      end

      BUILD_EXT = %w(
        .aux
        .log
        .out
      ).freeze
  
      BUILD_LOG = ['texput.log'].freeze
  
      def cleanup(tex)
        targets = BUILD_EXT.map { |ext| File.basename(tex, '.tex') + ext } + BUILD_LOG
        targets.each { |t| File.delete(t) if File.exist?(t) }
      end
    end
  end
end
