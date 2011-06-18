class Message
  include Mongoid::Document
  include Mongoid::Timestamps

  field :message
  field :location, :type => Array, :geo => true

  geo_index :location
end
