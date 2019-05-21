require "spec_helper"

describe(Jekyll::Tex::Builder) do
  let(:config) do 
    Jekyll.configuration({
      source: SOURCE_DIR,
      destination: DEST_DIR,
      gems: ["jekyll-tex"].freeze,
    })
  end

  let(:site) do
    Jekyll::Site.new(config)
  end

  let(:tex_path) do
    File.join("assets", "journal.pdf")
  end

  after(:each) do
    # Clean up the tex_path used
    File.delete source_dir(tex_path)
    File.delete dest_dir(tex_path)
  end

  it "generates PDF file from tex" do
    site.config["tex"] = {
      "source": source_dir("assets/tex"),
      "output": source_dir("assets"),
    }

    site.process

    expect(File.exists?(source_dir(tex_path))).to be_truthy
    expect(File.exists?(dest_dir(tex_path))).to be_truthy
  end
end
