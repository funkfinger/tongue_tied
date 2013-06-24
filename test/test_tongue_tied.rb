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
  
  def test_config_file_holds_value
    assert_equal 'bar', ENV['FOO']
  end
  
  def test_twilio_client
    @twilio_client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
    assert @twilio_client
  end
  
  def test_environment_variables_get_set_in_test_helper
    assert_equal 'localhost', ENV['DB_HOST']
  end
  
end