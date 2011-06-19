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
      config.grid_fs_access_url = "/images/uploads/"
    end
  end

  get '/' do
    erb :index
  end

  get '/images/uploads/*' do
    filename = env["PATH_INFO"].gsub("/images/uploads/", "")
    begin
      gridfs_file = Mongo::GridFileSystem.new(Mongoid.database).open(filename, 'r')
      gridfs_file.read
    rescue Exception => e
      puts e.message
      puts e.bactrace
    end
  end

  post '/messages' do
    message = params['message']['message']
    latitude = params['message']['lat']
    longitude = params['message']['long']

    new_message =
      if params['message']['image']
        Message.new(:message => message, :location => {:lat => latitude.to_f, :lng => longitude.to_f}, :image => params['message']['image'])
      else
        Message.new(:message => message, :location => {:lat => latitude.to_f, :lng => longitude.to_f})
      end
    new_message.save
    redirect '/messages'
  end

  get '/messages' do
    @messages = Message.all
    erb :messages
  end
end
