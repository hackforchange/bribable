require 'carrierwave'
require 'carrierwave/orm/mongoid'
require 'image_uploader'

class Message
  include Mongoid::Document
  include Mongoid::Timestamps

  field :message
  field :location, :type => Array, :geo => true

  geo_index :location
  mount_uploader :image, ImageUploader
end
