class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  storage :fog

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def default_url
    "/images/trollface.jpg"
  end

  process :resize_to_fill => [100, 100]
end
