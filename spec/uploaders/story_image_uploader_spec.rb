require 'carrierwave/test/matchers'

describe StoryImageUploader do
  include CarrierWave::Test::Matchers

  let(:story) { double('story') }
  let(:uploader) { StoryImageUploader.new(story, :image) }

  before do
    allow(story).to receive(:id).and_return(0)
    uploader.enable_processing = true
    uploader.store!(File.open("#{Rails.root}/spec/support/images/story_image.png"))
  end

  after do
    uploader.enable_processing = false
    #uploader.remove!
  end

  context "the huge version" do
    it "scales down to be exactly 1140 by 480 pixels" do
      expect(uploader.huge).to have_dimensions(1140, 480)
    end
  end

  context "the medium version" do
    it "is cropped down to exactly 205 by 305 pixels" do
      expect(uploader.medium).to have_dimensions(280, 305)
    end
  end

  it "makes the image writable only to the owner,readable for everybody and not executable" do
    expect(uploader).to have_permissions(0644)
  end

  it "respects the image format" do
    expect(uploader).to be_format('png')
  end
end
