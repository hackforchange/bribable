$:.unshift File.join(File.expand_path(File.dirname(__FILE__)))

require 'uri'
require 'mongo'
require 'sinatra'
require 'mongoid'
require 'mongoid_geo'
require 'message'
require 'pp'
require 'erb'
require 'carrierwave'
require 'image_uploader'

class BribableApp < Sinatra::Base
  set :root, File.dirname(__FILE__)

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
    CarrierWave.configure do |config|
      config.grid_fs_database = Mongoid.database.name
      config.grid_fs_host = Mongoid.config.master.connection.host
      config.storage = :grid_fs
      config.grid_fs_access_url = "/images"
    end
  end

  get '/' do
    erb :index
  end

  get '/images/uploads/*' do
    gridfs_path = env["PATH_INFO"].gsub("/images/", "")
    begin
      gridfs_file = Mongo::GridFileSystem.new(Mongoid.database).open(gridfs_path, 'r')
      self.response_body = gridfs_file.read
      self.content_type = gridfs_file.content_type
    rescue
      self.status = :file_not_found
      self.content_type = 'text/plain'
      self.response_body = ''
    end
  end

  post '/messages' do
    message = params['message']['message']
    latitude = params['message']['lat']
    longitude = params['message']['long']

    new_message = Message.new(:message => message, :location => {:lat => latitude.to_i, :lng => longitude.to_i})
    new_message.save
    redirect '/messages'
  end

  get '/messages' do
    @messages = Message.all
    erb :messages
  end
end
