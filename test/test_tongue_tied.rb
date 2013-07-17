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

  def test_text_message_is_required
    refute TextMessage.new({:body => "test"}).save
  end

  def test_text_message_has_number
    t = tm({"number" => "123456789"})
    assert_equal "123456789", t["number"]
  end

  # def test_text_message_creates_a_subscriber
  #   count = Subscriber.count
  #   tm
  #   assert_equal count + 1, Subscriber.count
  # end

  def test_text_message_has_keyword
    t = tm({"body" => "keyword"})
    assert_equal "keyword", t["keyword"], "keyword not created"
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