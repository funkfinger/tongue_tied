require File.expand_path '../test_helper.rb', __FILE__

class AssociationsTest < TongueTiedTests

  include Rack::Test::Methods

  ######## test below are in reverse cronological order....

  def test_text_message_creation
    tm = @t.text_messages.new(:body => "test", :from_number => "123456789", :to_number => "987654321")
    assert tm.save, "Failed to save - #{tm.inspect}"
  end
  
  def test_campaign_creation
    c = Campaign.new(:keyword => "newkey", :name => "name", :to_number => "1")
    assert c.save, "Failed to save - #{c.inspect}"
  end
  
  def test_subscriber_can_not_exist_on_own
    s = Subscriber.new(:from_number => "012345678")
    refute s.save, "Failed to save - #{s.inspect}"
  end
  
end