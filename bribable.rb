$:.unshift File.join(File.expand_path(File.dirname(__FILE__)))

require 'sinatra/base'
require 'mongoid'
require 'message'
require 'pp'
require 'erb'

class BribableApp < Sinatra::Base
  
  configure do
    Mongoid.configure do |config|
      name = "mongoid_development"
      host = "localhost"
      config.allow_dynamic_fields = false
      config.master = Mongo::Connection.new.db(name)
#      config.slaves = [
#        Mongo::Connection.new(host, 27018, :slave_ok => true).db(name),
#        Mongo::Connection.new(host, 27019, :slave_ok => true).db(name)
#      ]
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
