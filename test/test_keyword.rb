require File.expand_path '../test_helper.rb', __FILE__

class TongueTiedKeyword < TongueTiedTests

  include Rack::Test::Methods

  def tm(params = {})
    t = TextMessage.new(sample_text_message(params))
    assert t.save, "failed basic save - #{t.keyword.word}"
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
    assert_equal "KEY", t.keyword.word
    t = TextMessage.new(sample_text_message({"body" => " \nkey word\n "}))
    assert t.save
    assert_equal "KEY", t.keyword.word
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

  def test_text_message_has_keyword_and_is_uppercase
    t = tm({"body" => "keyword"})
    assert_equal "KEYWORD", t.keyword.word, "keyword not created"
  end

end