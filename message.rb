require 'carrierwave'
require 'carrierwave/orm/mongoid'
require 'image_uploader'

class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  extend Mongoid::Geo::Near

  field :message
  field :location, :type => Array, :geo => true

  geo_index :location
  mount_uploader :image, ImageUploader

  attr_accessor :s3_image_url

  def s3_image_url
    self.image.url
  end

  def view_url
    "/messages?lat=#{self.lat}&long=#{self.lng}"
  end
end
