require File.expand_path '../test_helper.rb', __FILE__

class TongueTiedOutgoingMessage < TongueTiedTests

  include Rack::Test::Methods

  def setup
    TestProviderSms.any_instance.unstub(:send_message)
    super
  end

  def test_outgoing_message_sent_flag_get_switched_upon_send
    om = @t.outgoing_messages.new(:message => 'blah')
    refute om.sent
  end

  def test_outgoing_message_has_sent_flag
    om = @t.outgoing_messages.new(:message => 'blah')
    refute om.sent
  end

  def test_message_sends_to_all_subscribers
    TestProviderSms.any_instance.stubs(:send_message).times(3)
    om = @t.outgoing_messages.new(:message => 'blah')
    om.subscribers << @t.subscribers.new(:from_number => '111')
    om.subscribers << @t.subscribers.new(:from_number => '222')
    om.subscribers << @t.subscribers.new(:from_number => '333')
    assert om.save
    om.send_message_to_all_subscribers("blab")    
  end


  def test_outgoing_message_sends_sms
    TestProviderSms.any_instance.stubs(:send_message).times(1)
    om = @t.outgoing_messages.new(:message => 'blah')
    sub = @t.subscribers.new(:from_number => '111')
    om.subscribers << sub
    assert om.save
    om.send_message_to_subscriber(sub, "blab")
  end

  def test_outgoing_message_has_subscribers
    om = @t.outgoing_messages.new(:message => 'blah')
    assert om.save
    assert_equal om.subscribers.all.count, 0
    s = @t.subscribers.new(:from_number => '111')
    om.subscribers << s
    assert om.save
    assert_equal om.subscribers.all.count, 1
  end

  def test_create_outgoing_message 
    om = @t.outgoing_messages.new(:message => 'blah')
    assert om.save
  end

  def test_class_exists
    assert_respond_to OutgoingMessage.new, :send_message_to_subscriber
  end

end