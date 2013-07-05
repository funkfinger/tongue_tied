ENV['RACK_ENV'] = 'test'

ENV['FOO']='bar'
ENV['TWILIO_ACCOUNT_SID']='AC50c36451e9ccffe77249b8ca05936b1a'
ENV['TWILIO_AUTH_TOKEN']='f1ec53e64dbffcbf80cd5d9662a15681'
ENV['DB_FLAVOR']='postgresql'
ENV['DB_HOST']='localhost'
ENV['DB_PORT']='5432'
ENV['DB_NAME']='tongue_tied_test'
ENV['DB_USER']='tongue_tied_user'
ENV['DB_PASS']='tongue_tied_pass'

require 'minitest/autorun'
require 'rack/test'

require File.expand_path '../../tongue_tied.rb', __FILE__

def app
  TongueTiedApp.new!
end

class TongueTiedTests < MiniTest::Unit::TestCase
  def setup
    DataMapper.auto_migrate!
  end
end
