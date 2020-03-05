# frozen_string_literal: true

require 'fileutils'
require 'open3'

module Jekyll
  module Tex
    class MissingBinaryError < ArgumentError
    end

    class CompileError < RuntimeError
    end

    # Currently we have a single compiler for pdflatex. If we ever need to,
    # we can support other latex compiler binaries, or even allow for users
    # to fully customize their compiler options (though this defeats the
    # purpose of this gem).
    class Compiler
      def self.compile(source, output_dir, options: [])
        unless installed?
          raise Jekyll::Tex::MissingBinaryError, 'pdflatex not found'
        end

        options += DEFAULT_OPTIONS
        _, _, status = Open3.capture3("pdflatex #{options.join(' ')} #{source}")

        # Path to the outputted PDF in /tmp if successfully compiled.
        base_name = File.basename(source, '.tex')
        pdf = File.join(WORKING_DIR, base_name + '.pdf')

        unless status.exitstatus.zero? && File.exist?(pdf)
          log = File.join(WORKING_DIR, base_name + '.log')
          raise Jekyll::Tex::CompileError, "Pdflatex failed with #{status.exitstatus} or file not found. " \
            "See buid logs for #{source} at #{log}."
        end

        # Move the file to the specified directory in the site, and clean up
        # the auxiliary files.
        FileUtils.move(pdf, File.join(output_dir, base_name + '.pdf'))
        cleanup(source)
      end

      WORKING_DIR = '/tmp'
      DEFAULT_OPTIONS = ['-halt-on-error', "-output-directory=#{WORKING_DIR}"].freeze

      def self.installed?
        @installed ||= begin
          _, _, status = Open3.capture3('pdflatex -version')
          status.exitstatus.zero?
        end
      end

      BUILD_EXT = %w[
        .aux
        .log
        .out
      ].freeze

      BUILD_LOG = ['texput.log'].freeze

      def self.cleanup(tex)
        aux_files = BUILD_EXT.map { |ext| File.basename(tex, '.tex') + ext } + BUILD_LOG
        aux_files.each do |f|
          tgt = File.join(WORKING_DIR, f)
          File.delete(tgt) if File.exist?(tgt)
        end
      end
    end
  end
end
