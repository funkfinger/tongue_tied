require File.expand_path '../test_helper.rb', __FILE__

class TextMessageTest < TongueTiedTests

  include Rack::Test::Methods

  def sample_text_message(params = {})
    def_params={
      "body" => "message",
      "to_number" => "0123456789",
      "from_number" => "9876543210"
    }.merge(params)
  end

  ######## test below are in reverse cronological order....

  def test_system_keyword_is_first_word_and_not_part_of_longer_word
    Subscriber.stubs(:unsubscribe).never
    t = TextMessage.new(:body => "nonstop", :to_number => "1111111111", :from_number => "2222222222")
    assert t.save
    t = TextMessage.new(:body => "stop_", :to_number => "1111111111", :from_number => "2222222222")
    assert t.save
    t = TextMessage.new(:body => "stopnon", :to_number => "1111111111", :from_number => "2222222222")
    assert t.save
  end

  def test_text_message_has_to_and_from_numbers
    t = TextMessage.new(:body => "body", :to_number => "1111111111", :from_number => "2222222222")
    assert t.save, "Failed to save - #{t.inspect}"
    t = TextMessage.new(:body => "body", :from_number => "2222222222")
    refute t.save, "Should fail, to field missing"
    t = TextMessage.new(:body => "body", :to_number => "2222222222")
    refute t.save, "Should fail, from field missing"
  end

  def test_text_message_possible_keyword_is_indifferent_to_whitespace
    t = TextMessage.new(sample_text_message({"body" => " key "}))
    assert t.save
    assert_equal "KEY", t.possible_keyword
    t = TextMessage.new(sample_text_message({"body" => " \nkey word\n "}))
    assert t.save
    assert_equal "KEY", t.possible_keyword
  end

  def test_fails_on_pure_whitespace_message
    refute TextMessage.new(sample_text_message({"body" => " "})).save
    refute TextMessage.new(sample_text_message({"body" => " \n "})).save
  end

  def test_text_message_can_not_be_more_than_160_chars
    str = ("A" * 161)
    t = TextMessage.new(sample_text_message({"body" => str}))
    refute t.save
    str = ("B" * 160)
    t = TextMessage.new(sample_text_message({"body" => str}))
    assert t.save
  end

  def test_text_message_is_required
    refute TextMessage.new({:body => "test"}).save
  end

end