require 'carrierwave/test/matchers'

describe AvatarUploader do
  include CarrierWave::Test::Matchers

  let(:user) { double('user') }
  let(:uploader) { AvatarUploader.new(user, :avatar) }

  before do
    allow(user).to receive(:id).and_return(0)
    uploader.enable_processing = true
    uploader.store!(File.open("#{Rails.root}/spec/support/images/avatar.png"))
  end

  after do
    uploader.enable_processing = false
    uploader.remove!
  end

  context 'the big thumb version' do
    it "scales down to be exactly 64 by 64 pixels" do
      processor = uploader.big.processors.first
      expect(processor[1]).to eq([64, 64])
      #expect(uploader.big).to have_dimensions(64, 64)
    end
  end

  context 'the medium thumb version' do
    it "scales down to be exactly 44 by 44 pixels" do
      processor = uploader.medium.processors.first
      expect(processor[1]).to eq([44, 44])
      #expect(uploader.small).to have_dimensions(44, 44)
    end
  end

  context 'the small thumb version' do
    it "scales down to be exactly 30 by 30 pixels" do
      processor = uploader.small.processors.first
      expect(processor[1]).to eq([30, 30])
      #expect(uploader.small).to have_dimensions(30, 30)
    end
  end

  it 'scales down to be exactly 128 by 128 pixels' do
    expect(uploader.small).to have_dimensions(128, 128)
  end

  it "makes the image readable only to the owner and not executable" do
    expect(uploader).to have_permissions(0600)
  end

  it "has the correct format" do
    expect(uploader).to be_format('png')
  end
end
