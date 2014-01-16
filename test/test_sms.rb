require File.expand_path '../test_helper.rb', __FILE__

class SmsTest < TongueTiedTests

  include Rack::Test::Methods

  def setup
    TestProviderSms.any_instance.unstub(:send_message)
    super
  end

  def test_can_send_multiple_messages
    TestProviderSms.any_instance.stubs(:send_message).times(5)
    sms = Sms.create('test_provider')
    sms.send_messages('message', 0, [1,2,3,4,5])
  end

  def test_sms_class_exists
    assert_respond_to Sms.new, :send_message
  end


end