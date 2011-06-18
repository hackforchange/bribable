$:.unshift File.join(File.expand_path(File.dirname(__FILE__)))

require 'bribable'
require 'test/unit'
require 'rack/test'

set :environment, :test

class BribableTest < Test::Unit::TestCase
  def test_home
    get '/'
    assert last_response.ok?
    assert_equal 'Hello World', last_response.body
  end

  def test_messages
    get '/messages'
    assert last_response.ok?
    assert_equal 'Hello World', last_response.body
  end

  def test_message_location
    get '/messages/'
    assert last_response.ok?
    assert_equal 'Hello World', last_response.body
  end
end
