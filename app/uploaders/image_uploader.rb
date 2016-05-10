class ImageUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick

  storage :file
  permissions 0644
  # storage :fog

  version :huge do
    process :resize_to_fit => [320, nil]
  end

  version :big, :from_version => :huge do
    process :resize_to_fit => [160, nil]
  end

  version :small, :from_version => :big do
    process :resize_to_fill => [30, 30]
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_whitelist
    %w(jpg jpeg gif png)
  end

  def content_type_whitelist
    /image\//
  end

  # def filename
  #   "#{SecureRandom.uuid}.jpg" if original_filename
  # end
  
end
