require File.expand_path '../test_helper.rb', __FILE__

class TongueTied < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  def app
    TongueTiedApp
  end
  
  
  def test_root_website_ok
    get '/'
    assert last_response.ok?
  end
    
  def test_twilio_client
    # run using foreman: foreman run bundle exec ruby test/test_tongue_tied.rb
      @twilio_client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
    assert @twilio_client
  end
  
  def test_environment_variables_get_set_in_test_helper
    # run using foreman: foreman run bundle exec ruby test/test_tongue_tied.rb
    assert_equal 'localhost', ENV['DB_HOST']
  end
  
end