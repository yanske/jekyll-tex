require "fileutils"

module Jekyll
  module Tex
    class Builder < Jekyll::Generator
      include Errors

      safe true

      CONFIG_KEY = "tex".freeze
  
      def generate(site)
        site_config = site.config[CONFIG_KEY] || {}
        @config = default_config.merge!(site_config.transform_keys(&:to_sym))

        Dir.glob(@config[:source] + '/*.tex') do |path|
          tex = File.basename(path)

          if update_pdf?(tex)
            build(tex)
            cleanup(tex)
          end
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
        system @config[:builder], *@config[:options], File.join(@config[:source], tex)

        pdf_path    = File.basename(tex, '.tex') + '.pdf'
        target_path = File.join(@config[:output], pdf_path)

        unless $?.exitstatus.zero? && File.exists?(File.basename(tex, '.tex') + '.pdf')
          raise BuildError
        end

        unless File.exists?(@config[:output])
          raise OutputError
        end

        FileUtils.move pdf_path, target_path
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
