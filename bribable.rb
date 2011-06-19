$:.unshift File.join(File.expand_path(File.dirname(__FILE__)))

require 'uri'
require 'mongo'
require 'sinatra'
require 'mongoid'
require 'mongoid_geo'
require 'message'
require 'pp'
require 'erb'

class BribableApp < Sinatra::Base
  :static
  configure do
    Mongoid.configure do |config|
      if ENV['MONGOHQ_URL']
        uri = URI.parse(ENV['MONGOHQ_URL'])
        conn = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
        config.master = conn.db(uri.path.gsub(/^\//, ''))
      else
        conn = Mongo::Connection.new("localhost")
        config.autocreate_indexes = true
        config.master = conn.db("bribabble_development")
      end
    end
  end

  get '/' do
    erb :index
  end

  post '/messages' do
    message = Message.new(:message => params['message'], :location => [])
    message.save
  end

  get '/messages' do
    latitude = params['lat'].to_i
    longitude = params['long'].to_i

    if latitude && longitude
      Message.near(:location => [latitude, longitude]).to_json
    end
  end
end
