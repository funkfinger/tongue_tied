ENV['RACK_ENV'] = 'test'
ENV['DB_NAME']='tongue_tied_test'

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
