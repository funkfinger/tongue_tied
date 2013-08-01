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
      "to_number" => "18005551212"
    }.merge(params)
  end

  ######## test below are in reverse cronological order....



  # def test_text_message_has_keyword_and_is_uppercase
  #   t = tm({"body" => "keyword"})
  #   assert_equal "KEYWORD", t.keyword.word, "keyword not created"
  # end

end