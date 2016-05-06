require 'carrierwave/test/matchers'

describe ImageUploader do
  include CarrierWave::Test::Matchers

  let(:node) { double('node') }
  let(:uploader) { ImageUploader.new(node, :image) }

  before do
    allow(node).to receive(:id).and_return(0)
    uploader.enable_processing = true
    uploader.store!(File.open("#{Rails.root}/spec/support/images/node_image.png"))
  end

  after do
    uploader.enable_processing = false
    #uploader.remove!
  end

  context "the huge version" do
    it "scales down to 320 pixels width" do
      expect(uploader.huge).to have_width(320)
    end
  end

  context "the big version" do
    it "scales down to 160 pixels width" do
      expect(uploader.big).to have_width(160)
    end
  end

  context "the small version" do
    it "scales down to be exactly 30 by 30 pixels" do
      expect(uploader.small).to have_dimensions(30, 30)
    end
  end

  it "makes the images readable only to the owner and not executable" do
    expect(uploader).to have_permissions(0600)
  end

  it "respects the image format" do
    expect(uploader).to be_format('png')
  end
end
