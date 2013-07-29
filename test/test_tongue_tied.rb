require File.expand_path '../test_helper.rb', __FILE__

class TongueTied < TongueTiedTests

  include Rack::Test::Methods
  
  def tm(params = {})
    t = TextMessage.new(sample_text_message(params))
    assert t.save, "failed basic save - #{t.body}"
    return t
  end
  
  def sample_text_message(params = {})
    def_params={
      "body" => "message",
      "number" => "18005551212"
    }.merge(params)
  end
  
######## test below are in reverse cronological order....


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