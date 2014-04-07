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

  def test_can_delete_keyword_via_api
    assert_equal 0, @t.keywords.all().count
    kw = @t.keywords.new(:word => 'word', :response => 'to your mother')
    @t.save
    @t.keywords.reload
    assert_equal 1, @t.keywords.all(:word => 'WORD').count
    delete "/api/telephony_account/#{@t.id}/keyword/#{kw.id}"
    follow_redirect!
    assert last_response.ok?
    assert_equal 0, @t.keywords.all().count
  end

  def test_delete_keyword_link_exists
    kw = @t.keywords.new(:word => 'word', :response => 'to your mother')
    @t.save
    get "/api/telephony_account/#{@t.id}/keyword/#{kw.id}"
    assert_match /delete keyword/, last_response.body
  end

  def test_can_update_keyword_via_api
    kw = @t.keywords.new(:word => 'word', :response => 'to your mother')
    @t.save
    kw.reload
    put "/api/telephony_account/#{@t.id}/keyword/#{kw.id}", { :word => 'wordsss', :response => 'to mommy' }
    follow_redirect!
    assert last_response.ok?
    kw.reload
    assert_equal 'to mommy', kw.response
  end

  def test_keyword_edit_page_has_esisting_values
    kw = @t.keywords.new(:word => 'word', :response => 'to your mother')
    @t.save
    kw.reload
    get "/api/telephony_account/#{@t.id}/keyword/#{kw.id}"
    assert last_response.ok?
  end

  def test_keyword_edit_page_exists
    kw = @t.keywords.new(:word => 'word', :response => 'to your mother')
    @t.save
    kw.reload
    get "/api/telephony_account/#{@t.id}/keyword/#{kw.id}"
    assert_equal "WORD", kw.word
    assert_equal "to your mother", kw.response
  end


  def test_keyword_page_has_edit_keyword_link
    kw = @t.keywords.new(:word => 'word', :response => 'to your mother')
    @t.save
    get "/api/telephony_account/#{@t.id}/keywords"
    assert_match /edit keyword/, last_response.body
  end

  def test_text_with_keyword_responds_with_text
    TestProviderSms.any_instance.stubs(:send_message).once.with('1', '111', 'to your mom')
    @t.keywords.new(:word => 'word', :response => 'to your mom')
    assert @t.save
    t = @t.text_messages.new("body" => "word", "from_number" => "111", :to_number => @t.number)
    t.save
  end

  def test_keyword_can_have_keyword_subscriber
    @t.keywords.new(:word => 'word', :response => 'to your mom')
    assert @t.save
    @t.reload
    kw = @t.keywords.first(:word => 'WORD')
    count = kw.subscribers.count
    s = @t.subscribers.new(:from_number => '111', :to_number => @t.number)
    kw.subscribers << s
    assert kw.save
    kw.reload
    assert_equal count + 1, kw.subscribers.count
  end

  def test_can_add_keyword_via_api
    count = @t.keywords.count
    post "/api/telephony_account/#{@t.id}/keyword", { :word => 'word', :response => 'to your mother' }
    follow_redirect!
    assert last_response.ok?
    assert_equal count + 1, @t.keywords.count
  end

  def test_keyword_has_a_response
    @t.keywords.new(:word => 'word', :response => 'to your mother')
    assert @t.save
  end

  def test_keyword_list_page_exists
    get "/api/telephony_account/#{@t.id}/keywords"
    assert last_response.ok?
  end

  # def test_text_message_has_keyword_and_is_uppercase
  #   t = tm({"body" => "keyword"})
  #   assert_equal "KEYWORD", t.keyword.word, "keyword not created"
  # end

end