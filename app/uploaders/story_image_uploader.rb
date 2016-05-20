class StoryImageUploader < BasePictureUploader

  version :huge do
    process :resize_to_fill => [1140, 480]
  end

  version :medium, :from_version => :huge do
    process :crop => '280x305+430+87'
  end

  version :small, :from_version => :huge do
    process :resize_to_fill => [128, 128]
  end

  private

  def crop(geometry)
    manipulate! do |img|
      img.crop(geometry)
      img
    end
  end
  
end
