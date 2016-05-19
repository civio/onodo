require 'carrierwave/test/matchers'

describe ChapterImageUploader do
  include CarrierWave::Test::Matchers

  let(:chapter) { double('chapter') }
  let(:uploader) { ChapterImageUploader.new(chapter, :image) }

  before do
    allow(chapter).to receive(:id).and_return(0)
    uploader.enable_processing = true
    uploader.store!(File.open("#{Rails.root}/spec/support/images/chapter_image.png"))
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

  it "makes the image writable only to the owner,readable for everybody and not executable" do
    expect(uploader).to have_permissions(0644)
  end

  it "respects the image format" do
    expect(uploader).to be_format('png')
  end
end
