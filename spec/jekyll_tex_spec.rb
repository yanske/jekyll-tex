# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/jekyll-tex/compiler.rb'

describe(Jekyll::Tex::Builder) do
  let(:config) do
    Jekyll.configuration({
                           source: SOURCE_DIR,
                           destination: DEST_DIR,
                           gems: ['jekyll-tex']
                         })
  end

  let(:site) do
    Jekyll::Site.new(config)
  end

  # To ensure that files don't conflict between each other in tests,
  # we pass around an appendable list of file names that is cleaned
  # up after each test.
  before(:all) do
    @cleanup_list = []
  end

  after(:each) do
    @cleanup_list.each { |file| clean_file(file) }
  end

  it 'generates PDF file from tex' do
    site.config['tex'] = {
      "source": 'good',
      "output": 'good'
    }

    site.process

    tex_path = File.join('good', 'good.pdf')

    @cleanup_list << source_dir(tex_path)
    @cleanup_list << dest_dir(tex_path)

    # PDFs created.
    expect(File.exist?(source_dir(tex_path))).to be_truthy
    expect(File.exist?(dest_dir(tex_path))).to be_truthy

    # Auxiliary files cleaned up on success.
    expect(File.exist?('/tmp/good.log')).to be_falsey
  end

  it 'does not build PDF if up to date' do
    site.config['tex'] = {
      "source": 'good',
      "output": 'good'
    }

    tex_path = File.join('good', 'good.pdf')
    stub_updated_pdf(tex_path)

    site.process

    expect(File.exist?(source_dir(tex_path))).to be_falsey
    expect(File.exist?(dest_dir(tex_path))).to be_falsey
  end

  it 'raises compile error pointing to logs on failure' do
    site.config['tex'] = {
      "source": 'bad',
      "output": 'bad'
    }

    expect { site.process }.to raise_error(
      Jekyll::Tex::CompileError, %r{/tmp/bad\.log}
    )
  end
end
