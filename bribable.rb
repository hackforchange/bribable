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
      config.storage = :fog
      config.fog_credentials = {
        :provider => 'AWS',
        :aws_access_key_id => ENV['S3_KEY'],
        :aws_secret_access_key => ENV['S3_SECRET'],
        :region => 'us-east-1' # optional, defaults to 'us-east-1'
      }
      config.fog_directory = 'bribable_development'
      config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}
    end
  end

  get '/' do
    erb :index
  end

  post '/messages' do
    user_lat = params['initial']['lat']
    user_long = params['initial']['long']
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
    redirect "/messages?lat=#{user_lat}&long=#{user_long}"
  end

  get '/messages' do
    latitude = params['lat']
    longitude = params['long']

    if request.xhr?
      Message.geo_near([latitude.to_f, longitude.to_f], :location).desc(:created_at).to_json(:methods => :s3_image_url)
    else
      erb :messages
    end
  end
end

