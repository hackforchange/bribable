$:.unshift File.join(File.expand_path(File.dirname(__FILE__)))

require 'uri'
require 'mongo'
require 'sinatra'
require 'mongoid'
require 'message'
require 'pp'
require 'erb'

class BribableApp < Sinatra::Base
  
  configure do
    Mongoid.configure do |config|
      if ENV['MONGOHQ_URL']
        uri = URI.parse(ENV['MONGOHQ_URL'])
        conn = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
        config.master = conn.db(uri.path.gsub(/^\//, ''))
      else
        conn = Mongo::Connection.new("localhost")
        config.master = conn.db("bribabble_development")
      end
    end
  end

  get '/' do
    erb :index
  end

  post '/messages' do
    message = Message.new(:message => params['message'])
    message.save
  end

  get '/messages' do
    Message.all.to_json
  end
  

  
end
