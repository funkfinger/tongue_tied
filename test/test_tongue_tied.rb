require File.expand_path '../test_helper.rb', __FILE__

class TongueTied < TongueTiedTests

  include Rack::Test::Methods
  
  def tm(params = {})
    t = TextMessage.new(sample_text_message(params))
    assert t.save
    return t
  end
  
  def sample_text_message(params = {})
    def_params={
      "body" => "message",
      "number" => "18005551212"
    }.merge(params)
  end
  
######## test below are in reverse cronological order....

  def test_keyword_is_indifferent_to_whitespace
    t = TextMessage.new(sample_text_message({"body" => " key "}))
    assert t.save
    assert_equal "KEY", t.keyword
    t = TextMessage.new(sample_text_message({"body" => " \nkey word\n "}))
    assert t.save
    assert_equal "KEY", t.keyword
  end

  def test_fails_on_pure_whitespace_message
    refute TextMessage.new(sample_text_message({"body" => " "})).save
    refute TextMessage.new(sample_text_message({"body" => " \n "})).save
  end

  def test_stop_keyword_deactivates_subscriber_and_is_case_indifferent
    t = tm
    assert t.subscriber.active
    t = tm("body" => "stop")
    refute t.subscriber.active
    t = tm
    assert t.subscriber.active
    t = tm("body" => "sToP")
    refute t.subscriber.active    
  end

  def test_subscriber_is_reactivated_if_new_message_is_received
    t = tm
    t.subscriber.active = false
    assert t.save
    t = tm
    assert t.subscriber.active
  end

  def test_subscriber_is_active_on_new_message
    t = tm
    assert t.subscriber.active
  end

  def test_new_subscriber_is_not_created_if_already_exists
    params = {"number" => "12223334444", "body" => "blah"}
    tm(params)
    assert 1, TextMessage.count
    assert 1, Subscriber.count
    t = tm(params)
    assert 2, TextMessage.count
    assert 1, Subscriber.count
    assert_equal params["number"], t.subscriber.number
  end

  def test_text_message_is_required
    refute TextMessage.new({:body => "test"}).save
  end

  def test_text_message_has_number
    t = tm({"number" => "123456789"})
    assert_equal "123456789", t["number"]
  end

  def test_text_message_creates_a_subscriber
    count = Subscriber.count
    tm
    assert_equal count + 1, Subscriber.count
    assert_equal tm.subscriber.number, tm.number
  end

  def test_text_message_has_keyword_and_is_uppercase
    t = tm({"body" => "keyword"})
    assert_equal "KEYWORD", t["keyword"], "keyword not created"
  end

  def test_text_message_can_not_be_more_than_160_chars
    str = ("A" * 161)
    t = TextMessage.new(sample_text_message({"body" => str}))
    refute t.save
    str = ("B" * 160)
    t = TextMessage.new(sample_text_message({"body" => str}))
    assert t.save
  end

  def test_text_message_has_creation_date_and_is_a_date
    refute tm.created_at.nil?
    assert_equal Time.now.day, tm.created_at.day
  end  

  def test_text_message_has_body
    refute tm({:body => 'body text'}).body.nil?
  end  

  def test_create_text_message
    refute tm.nil?
  end

  def test_environment_variables_get_set_in_test_helper
    # run using foreman: foreman run bundle exec ruby test/test_tongue_tied.rb
    assert_equal 'localhost', ENV['DB_HOST']
  end
  
  def test_root_website_ok
    get '/'
    assert last_response.ok?
  end

end