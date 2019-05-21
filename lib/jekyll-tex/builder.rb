require "fileutils"

module Jekyll
  module Tex
    class Builder < Jekyll::Generator
      include Errors

      safe true
      priority :lowest

      CONFIG_KEY = "tex".freeze
  
      def generate(site)
        @site = site

        site_config = @site.config[CONFIG_KEY] || {}
        @config = default_config.merge!(site_config.transform_keys(&:to_sym))
        Dir.glob(File.join(@site.source, @config[:source]) + '/*.tex') do |path|
          tex = File.basename(path)

          build(tex)
          cleanup(tex)
        end
      end

      private

      def update_pdf?(tex)
        # Validate here that PDF is not up to date or does not exist
        true
      end

      def default_config
        {
          builder: 'pdflatex',
          options: ['--interaction=batchmode'],
          source:  'assets/tex',
          output:  'assets',
        }
      end

      def build(tex)
        system @config[:builder], *@config[:options], File.join(@site.source, @config[:source], tex)

        pdf_file    = File.basename(tex, '.tex') + '.pdf'
        target_path = File.join(@site.source, @config[:output], pdf_file)

        # The builder outputs the PDF file in the top level directory of the site. We need to
        # move it to the source directory, and add it to the site's inventory.
        unless $?.exitstatus.zero? && File.exists?(pdf_file)
          raise BuildError
        end

        FileUtils.move pdf_file, target_path
        @site.static_files << StaticFile.new(@site, @site.source, @config[:output], pdf_file)
      end

      BUILD_EXT = %w(
        .aux
        .log
        .out
      ).freeze
  
      BUILD_LOG = ['texput.log'].freeze
  
      def cleanup(tex)
        targets = BUILD_EXT.map { |ext| File.basename(tex, '.tex') + ext } + BUILD_LOG
        targets.each { |t| File.delete(t) if File.exists?(t) }
      end
    end
  end
end
