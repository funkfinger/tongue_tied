ENV['RACK_ENV'] = 'test'
ENV['DB_NAME']='tongue_tied_test'

require 'minitest/autorun'
require 'rack/test'
require 'fakeweb'
require 'machinist-dm'
require 'sinatra/sessionography'
# require 'rack/flash/test'
require 'mocha/setup'

require File.expand_path '../../tongue_tied.rb', __FILE__

FakeWeb.register_uri(:post, "http://broadcast.betwext.com/subscribers/create_subscriber", :body => "", :status => ["302", "Found"])

def app
  TongueTiedApp.helpers Sinatra::Sessionography
  TongueTiedApp.new!
end

class TongueTiedTests < MiniTest::Unit::TestCase
  include Rack::Test::Methods
  def setup
    Sinatra::Sessionography.session.clear
    DataMapper.auto_migrate!
    @t = TelephonyAccount.new(:number => '1', :provider => 'test_provider')
    @t.save
  end
end

class Sms
  def self.create(type)
    case type
    when 'twilio'
      @sms_provider = TwilioSms.new
    when 'plivo'
      @sms_provider = PlivoSms.new
    when 'test_provider'
      @sms_provider = TestProviderSms.new
    else
    end
  end
  @sms_provider
end

class TestProviderSms < Sms
  def send_message(from_number, to_number, message)
    true
  end
end


