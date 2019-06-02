require "spec_helper"

describe(Jekyll::Tex::Builder) do
  let(:config) do
    Jekyll.configuration({
      source: SOURCE_DIR,
      destination: DEST_DIR,
      gems: ["jekyll-tex"],
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

  it "generates PDF file from tex" do
    site.config["tex"] = {
      "source": "no_pdf/tex",
      "output": "no_pdf",
    }

    site.process

    tex_path = File.join("no_pdf", "journal.pdf")

    @cleanup_list << source_dir(tex_path)
    @cleanup_list << dest_dir(tex_path)

    expect(File.exist?(source_dir(tex_path))).to be_truthy
    expect(File.exist?(dest_dir(tex_path))).to be_truthy
  end

  it "does not build PDF if up to date" do
    site.config["tex"] = {
      "source": "paper",
      "output": "paper",
    }

    tex_path = File.join("paper", "paper.pdf")

    # Stub and say that we do have paper.pdf.
    allow(File).to receive(:exist?)
    expect(File).to receive(:exist?).with(source_dir(tex_path)).and_return(true)

    # Let all files have the same last modified time.
    allow(File).to receive(:mtime).and_return(1)

    site.process

    expect(File.exist?(source_dir(tex_path))).to be_falsey
    expect(File.exist?(dest_dir(tex_path))).to be_falsey
  end
end
