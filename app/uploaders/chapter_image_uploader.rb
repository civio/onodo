class ChapterImageUploader < BasePictureUploader

  version :huge do
    process :resize_to_fit => [320, nil]
  end

  version :big, :from_version => :huge do
    process :resize_to_fit => [160, nil]
  end
  
  version :medium, :from_version => :huge do
    process :resize_to_fill => [128, 128]
  end

end
