class Message
  include Mongoid::Document
  include Mongoid::Timestamps

  field :message
  field :location
end
