class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  storage :fog

  def extension_white_list
    %w(jpg jpeg gif png)
  end


  process :resize_to_fill => [100, 100]
end
