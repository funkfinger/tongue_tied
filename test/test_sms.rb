require File.expand_path '../test_helper.rb', __FILE__

class SmsTest < TongueTiedTests

  include Rack::Test::Methods

  def test_can_send_multiple_messages
    

  end

  def test_sms_class_exists
    assert_respond_to Sms.new, :send_message
  end


end