ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'

require File.expand_path '../../tongue_tied.rb', __FILE__

class TongueTiedTests < MiniTest::Unit::TestCase
  def setup
    DataMapper.auto_migrate!
  end
end
