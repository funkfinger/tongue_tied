require File.expand_path '../test_helper.rb', __FILE__

class TongueTiedSubscriber < TongueTiedTests

  def test_subscriber_has_active_subscribers
    @t.subscribers.new(:from_number => '1', :active => false)
    @t.subscribers.new(:from_number => '2')
    @t.subscribers.new(:from_number => '3')
    assert @t.save
    assert_equal 3, @t.subscribers.count
    assert_equal 2, @t.subscribers.active_subscribers.count
  end

  def test_subscribers_list_page_exists_and_contains_subscribers
    @t.subscribers.new(:from_number => '911')
    @t.save
    get "/api/telephony_account/#{@t.id}/subscribers"
    assert last_response.ok?
    assert_match "911", last_response.body
  end

  def test_subscriber_belongs_to_telephony_account
    assert @t.subscribers.new(:from_number => '111').save
  end


  def test_subscriber_has_creation_date
    s = @t.subscribers.new(:from_number => '111')
    assert s.save
    refute s.created_at.nil?
  end

  def test_text_message_creates_a_subscriber
    count = Subscriber.count
    assert Subscriber.first(:from_number => "111").nil?
    t = @t.text_messages.new("body" => "blah me", "from_number" => '111', :to_number => '222')
    t.save
    assert_equal count + 1, Subscriber.count
    refute Subscriber.first(:from_number => "111").nil?
  end

  def test_new_subscriber_is_not_created_if_already_exists
    params = {"to_number" => "12223334444", "body" => "blah", "from_number" => "222"}
    t = @t.text_messages.new(params)
    t.save
    assert_equal 1, TextMessage.count, "number of text messages is incorrect"
    assert_equal 1, Subscriber.count
    t = @t.text_messages.new(params)
    t.save
    assert_equal 2, TextMessage.count
    assert_equal 1, Subscriber.count
    assert_equal params["from_number"], Subscriber.first.from_number
  end

  def test_subscriber_is_active_on_new_message
    t = @t.text_messages.new("body" => "blah me", "from_number" => "1212", :to_number => "2121")
    t.save
    assert Subscriber.first(:from_number => "1212").active
  end

  def test_new_message_reactivates_subscriber
    s = @t.subscribers.new(:from_number => '111')
    assert s.save
    assert s.active
    Subscriber.unsubscribe(TextMessage.new("body" => "doesnt matter", "from_number" => "111", :to_number => "222"))
    s.reload
    refute s.active
    t = @t.text_messages.new("body" => "nostop", "from_number" => "111", :to_number => "222")
    assert t.save
    s.reload
    assert s.active, "Should be active after non-stop message - #{s.inspect}"
  end

  def test_can_deactivate
    s = @t.subscribers.new(:from_number => '111')
    assert s.save
    assert s.active, "should be active"
    Subscriber.unsubscribe(TextMessage.new("body" => "doesnt matter", "from_number" => "111", :to_number => '222'))
    s.reload
    refute s.active, "should be deactive - #{Subscriber.all.inspect}"
  end

  def test_stop_keyword_deactivates_subscriber_and_is_case_indifferent
    t = @t.text_messages.new("body" => "message", "from_number" => "111", :to_number => "222")
    assert t.save
    s = @t.subscribers.first(:from_number => "111")
    assert s.active
    t = @t.text_messages.new("body" => "stop", "from_number" => "111", :to_number => "222")
    assert t.save
    s.reload
    refute s.active
    t = @t.text_messages.new("body" => "message", "from_number" => "111", :to_number => "222")
    assert t.save
    s.reload
    assert s.active
    t = @t.text_messages.new("body" => "StOp", "from_number" => "111", :to_number => "222")
    assert t.save
    s.reload
    refute s.active
  end

end