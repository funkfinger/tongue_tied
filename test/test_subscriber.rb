require File.expand_path '../test_helper.rb', __FILE__

class TongueTiedSubscriber < TongueTiedTests


  def setup
    DataMapper.auto_migrate!
    @camp = Campaign.first_or_create(:name => "camp name", :keyword => "blah", :to_number => to_number)
  end

  # def self.teardown
  #   Campaign.all.destroy
  # end

  def to_number
    '12223334444'
  end


  def test_text_message_creates_a_subscriber
    count = Subscriber.count
    assert @camp.subscribers.first(:from_number => "1212").nil?
    t = TextMessage.new("body" => "blah me", "from_number" => "1212", :to_number => to_number)
    t.save
    assert_equal count + 1, Subscriber.count
    refute @camp.subscribers.first(:from_number => "1212").nil?
  end

  def test_new_subscriber_is_not_created_if_already_exists
    params = {"to_number" => "12223334444", "body" => "blah", "from_number" => "222"}
    t = TextMessage.new(params)
    t.save
    assert_equal 1, TextMessage.count, "number of text messages is incorrect"
    assert_equal 1, Subscriber.count
    t = TextMessage.new(params)
    t.save
    assert_equal 2, TextMessage.count
    assert_equal 1, Subscriber.count
    assert_equal params["from_number"], Subscriber.first.from_number
  end

  def test_subscriber_is_active_on_new_message
    t = TextMessage.new("body" => "blah me", "from_number" => "1212", :to_number => "12223334444")
    t.save
    assert @camp.subscribers.first(:from_number => "1212").active
  end

  def test_new_message_reactivates_subscriber
    s = @camp.subscribers.new(:from_number => "2222222222")
    assert @camp.save
    assert s.active
    Subscriber.unsubscribe(TextMessage.new("body" => "doesnt matter", "from_number" => "2222222222", :to_number => "12223334444"))
    s.reload
    refute s.active
    t = TextMessage.new("body" => "nostop", "from_number" => "2222222222", :to_number => "12223334444")
    assert t.save
    s.reload
    assert s.active, "Should be active after non-stop message - #{s.inspect}"
  end

  def test_can_deactivate
    s = @camp.subscribers.new(:from_number => "2222222222")
    assert @camp.save
    assert s.active, "should be active"
    Subscriber.unsubscribe(TextMessage.new("body" => "doesnt matter", "from_number" => "2222222222", :to_number => to_number))
    s.reload
    refute s.active, "should be deactive - #{Subscriber.all.inspect}"
  end

  def test_stop_keyword_deactivates_subscriber_and_is_case_indifferent
    c = Campaign.new(:name => "camp name", :keyword => "message", :to_number => "9999999999")
    assert c.save
    t = TextMessage.new("body" => "message", "from_number" => "18005551212", :to_number => "9999999999")
    assert t.save
    assert c.subscribers.first(:from_number => "18005551212").active
    t = TextMessage.new("body" => "stop", "from_number" => "18005551212", :to_number => "9999999999")
    assert t.save
    c.reload
    refute c.subscribers.first(:from_number => "18005551212").active, "#{c.subscribers.first(:from_number => "18005551212").campaign.inspect}"
  end

end