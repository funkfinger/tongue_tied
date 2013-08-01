require File.expand_path '../test_helper.rb', __FILE__

class AssociationsTest < TongueTiedTests

  include Rack::Test::Methods

  ######## test below are in reverse cronological order....

  def test_text_message_creation
    tm = TextMessage.new(:body => "test", :from_number => "123456789", :to_number => "987654321")
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
  
  def test_subscriber_belongs_to_campaign
    c = Campaign.new(:keyword => "newkey", :name => "name", :to_number => "1")
    c.subscribers.new(:from_number => "012345678")
    assert c.save, "Failed to save - #{c.inspect}"
  end
  
  def test_subscriber_is_created_if_campaign_exists_on_text_message_creation
    c = Campaign.new(:keyword => "newkey", :name => "name", :to_number => "987654321")
    assert c.save
    assert_equal 0, c.subscribers.count
    tm = TextMessage.new(:body => "newkey", :from_number => "123456789", :to_number => "987654321")
    assert tm.save
    assert_equal 1, c.subscribers.count
    assert c.subscribers.first(:from_number => "123456789")
  end

end