require File.expand_path '../test_helper.rb', __FILE__

class SmsTest < TongueTiedTests

  include Rack::Test::Methods

  def setup
    TestProviderSms.any_instance.unstub(:send_message)
    super
  end

  def test_send_messages_api_halts_500_on_bad_telephony_account_id
    post '/api/sms', {:telephony_account_id => 'a', :message => 'bad t.a. id', :numbers => [1]}
    refute last_response.ok?
  end

  def test_send_messages_api_halts_500_without_correct_data
    variations = [
      {},
      {:telephony_account_id => @t.id, :message => "hello there"},
      {:telephony_account_id => @t.id, :numbers => [1,2,3]},
      {:message => "hello there", :numbers => [1,2,3]}
    ]
    variations.each do |v|
      post '/api/sms', v
      refute last_response.ok?, "should be a bad response, but it turned up ok..."
    end
  end

  def test_can_send_messages_via_api
    TestProviderSms.any_instance.stubs(:send_message).times(5)
    post '/api/sms', {:telephony_account_id => @t.id, :message => "hello there", :numbers => [1,2,3,4,5]}
    assert last_response.ok?
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