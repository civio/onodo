class UserAvatarUploader < BasePictureUploader

  version :huge do
    process :resize_to_fill => [128, 128]
  end

  version :big, :from_version => :huge do
    process :resize_to_fill => [64, 64]
  end

  version :medium, :from_version => :big do
    process :resize_to_fill => [44, 44]
  end

  version :small, :from_version => :medium do
    process :resize_to_fill => [30, 30]
  end

  def default_url
    ActionController::Base.helpers.asset_path("images/default/" + [version_name, "avatar.png"].compact.join('_'))
  end

end
