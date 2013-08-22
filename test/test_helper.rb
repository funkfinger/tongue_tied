ENV['RACK_ENV'] = 'test'
ENV['DB_NAME']='tongue_tied_test'

require 'minitest/autorun'
require 'rack/test'
require 'fakeweb'
require 'machinist-dm'
require 'mocha/setup'
require 'sinatra/sessionography'
# require 'rack/flash/test'

require File.expand_path '../../tongue_tied.rb', __FILE__

FakeWeb.register_uri(:post, "http://broadcast.betwext.com/subscribers/create_subscriber", :body => "", :status => ["302", "Found"])

def app
  TongueTiedApp.helpers Sinatra::Sessionography
  TongueTiedApp.new!
end

class TongueTiedTests < MiniTest::Unit::TestCase
  include Rack::Test::Methods
  def setup
    DataMapper.auto_migrate!
  end
end

