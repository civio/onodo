class NodeImageUploader < BasePictureUploader

  version :huge do
    process :resize_to_fit => [320, nil]
  end

  version :big, :from_version => :huge do
    process :resize_to_fit => [160, nil]
  end

  version :small, :from_version => :big do
    process :resize_to_fill => [30, 30]
  end
  
end
