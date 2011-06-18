$:.unshift File.join(File.expand_path(File.dirname(__FILE__)))

require 'uri'
require 'mongo'
require 'sinatra/base'
require 'mongoid'
require 'message'
require 'pp'

class BribableApp < Sinatra::Base
  configure do
    Mongoid.configure do |config|
      uri = URI.parse(ENV['MONGOHQ_URL'])
      conn = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
      config.master = conn.db(uri.path.gsub(/^\//, ''))
    end
  end

  get '/' do
    "Hello World"
  end

  post '/messages' do
    message = Message.new(:message => params['message'])
    message.save
  end

  get '/messages' do
    Message.all.to_json
  end
end
