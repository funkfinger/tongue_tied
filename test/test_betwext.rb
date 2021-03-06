require File.expand_path '../test_helper.rb', __FILE__

class TongueTiedBetwext < TongueTiedTests

  include Rack::Test::Methods

  def betwext_url_is_not_a_404
    get '/api/betwext/sms'
    assert last_response.ok?
  end

  def sample_betwext_request( params={} )
    def_params = {
      "message_id" => "a",                # Our unique ID of that specific incoming message
      "sender_number" => "8005551212",    # The number of the cellular device that sent the message to your Betwext Pro Keyword
      "recipient_number" => "8005001212", # Your Betwext Pro phone number that received the message
      "message" => "blah",                # The entire contents of the text message sent to your Betwext Pro account
      "time_received" => "",              # The unix timestamp (GMT) when we received the message
      "keyword" => "keyword"              # The first word of the message, and the keyword we parsed the message as containing.
    }.merge( params )
  end

  def create_betwext( params={} )
    post '/api/betwext/sms', sample_betwext_request( params )
    assert last_response.ok?, "Post failed"
  end
  
  def br_hash
    num = 1112223333
    {:raw => 'blah', :message_id => "a", :sender_number => num, :recipient_number => 8005001212, :message => "blah", :time_received => "", :keyword => "blah"}
  end 

  ######## test below are in reverse cronological order....
    
  def test_song_request_list
    create_betwext({ 'message' => 'request national anthem', 'keyword' => 'request' })
    get '/api/betwext/requests'
    assert last_response.ok?, "get failed"
    assert_match /national anthem/, last_response.body    
  end
    
  def test_betwext_request_creates_subscriber
    num = 1112223333
    s = betwext_ta.subscribers.first(:conditions => {:from_number => num})
    assert s.nil?
    br = BetwextRequest.new( br_hash)
    assert br.save
    s = betwext_ta.subscribers.first(:conditions => {:from_number => num})
    assert s, betwext_ta.subscribers.all.inspect   
  end
  
  def test_betwext_keyword_creates_tt_keyword
    k = Keyword.first(:word => 'ttkeyword'.upcase)
    refute k
    b = BetwextKeyword.new(:keyword => 'ttkeyword')
    assert b.save
    k = Keyword.first(:word => 'ttkeyword'.upcase)
    assert k, k.inspect
  end  

  def test_keyword_has_creation_date
    b = BetwextKeyword.new(:keyword => 'blah')
    b.save
    assert b.created_at
  end

  def test_keyword_list_is_sorted_by_creation_date_desc
    create_betwext({ :keyword => 'sort1' })
    create_betwext({ :keyword => 'sort2' })
    create_betwext({ :keyword => 'sort3' })
    create_betwext({ :keyword => 'sort4' })
    get '/api/betwext/keyword_list'
    assert_match /SORT4.*?SORT3.*?SORT2.*?SORT1/m, last_response.body
  end

  def test_keyword_list_is_unique
    create_betwext({ :keyword => 'clickable_key' })
    create_betwext({ :keyword => 'clickable_key' })
    create_betwext({ :keyword => 'click_key' })
    get '/api/betwext/keyword_list'
    refute_match /CLICKABLE\_KEY.*?CLICKABLE\_KEY.*?CLICKABLE\_KEY/m, last_response.body
    assert_match /CLICK\_KEY.*?CLICK\_KEY.*?CLICKABLE\_KEY.*?CLICKABLE\_KEY/m, last_response.body
  end

  def test_bewext_request_does_not_create_duplicate_number_keyword_pair
    create_betwext({ 'sender_number' => '01234567890', 'keyword' => 'key_word' })
    assert_equal 1, BetwextRequest.count
    create_betwext({ 'sender_number' => '01234567890', 'keyword' => 'key_word' })
    assert_equal 1, BetwextRequest.count    
    assert_equal 'exists', last_response.body
  end

  def test_add_to_betwext_list_also_adds_to_winner_list
    create_betwext
    req = BetwextRequest.first
    list_id = 999
    assert BetwextWinner.count, 0
    get "/api/betwext/add_to_betwext_list/#{req.keyword}/#{list_id}/#{req.sender_number}"
    assert BetwextWinner.count, 1
    assert_equal req.betwext_winners.first(:betwext_list_id => list_id).betwext_list_id, list_id
  end

  def test_add_to_betwext_list_link
    create_betwext
    req = BetwextRequest.first
    get "/api/betwext/add_to_betwext_list/#{req.keyword}/4244/#{req.sender_number}"
    assert last_response.redirect?
  end

  def test_betwext_keyword_page_displays_text_number
    create_betwext({ :keyword => 'clickable_key', :sender_number => '1234567890' })
    get '/api/betwext/keyword/clickable_key'
    assert last_response.ok?
    assert_match /1234567890/, last_response.body, "Can't find the number on the page"
  end

  def test_list_betwext_keyword_is_clickable
    create_betwext({ :keyword => 'clickable_key' })
    get '/api/betwext/keyword_list'
    assert last_response.ok?
    assert_match /\<a href\=\'(.*?)\'\>CLICKABLE_KEY\<\/a\>/, last_response.body, "Can't find clickable keyword"
  end

  def test_list_betwext_keywords
    create_betwext({ :keyword => 'found_me_key' })
    get '/api/betwext/keyword_list'
    assert last_response.ok?
    assert_match /FOUND_ME_KEY/, last_response.body, "Can't find me"
  end

  def test_betwext_request_message_field_is_required
    params = sample_betwext_request
    params.delete('message')
    post '/api/betwext/sms', params
    refute last_response.ok?
  end

  def test_betwext_request_sender_number_field_is_required
    params = sample_betwext_request
    params.delete('sender_number')
    post '/api/betwext/sms', params
    refute last_response.ok?
  end

  def test_betwext_request_keyword_field_is_required
    params = sample_betwext_request
    params.delete('keyword')
    post '/api/betwext/sms', params
    refute last_response.ok?
  end

  def test_betwext_keyword_is_created
    post '/api/betwext/sms', sample_betwext_request({ :keyword => 'new_key'})
    assert last_response.ok?, "Post failed"
    keyword = BetwextKeyword.first( :keyword => 'NEW_KEY' )
    refute keyword.nil?
    assert_equal keyword.keyword, 'NEW_KEY'
  end

  def test_list_betwext_entries
    post '/api/betwext/sms', sample_betwext_request({ :message => 'found me'})
    assert last_response.ok?, "Post failed"
    get '/api/betwext/list'
    assert last_response.ok?, "Get failed"
    assert_match /found me/, last_response.body, "Can't find me"
  end

  def test_betwext_api_accepts_bad_key_value_pair
    post '/api/betwext/sms', sample_betwext_request({ 'bad_key' => 'bad_value' })
    assert last_response.ok?, "Post failed"
  end

  def test_betwext_api_contains_correct_values
    post '/api/betwext/sms', sample_betwext_request({ 'message_id' => 'test_id' })
    assert last_response.ok?, "Post failed"
    message = BetwextRequest.first( :message_id => 'test_id' )
    refute message.nil?
    assert_equal message.message_id, 'test_id'
    assert_equal message.sender_number, sample_betwext_request['sender_number']
    assert_equal message.recipient_number, sample_betwext_request['recipient_number']
    assert_equal message.message, sample_betwext_request['message']
    assert_equal message.time_received, sample_betwext_request['time_received']
    assert_equal message.keyword, sample_betwext_request['keyword']
  end

  def test_betwext_api_creates_betwexed_entry
    db_count = BetwextRequest.count
    post '/api/betwext/sms', sample_betwext_request
    assert last_response.ok?, "Post failed"
    assert_equal db_count + 1, BetwextRequest.count
  end

  def test_betwext_api_endpoint_exists
    post '/api/betwext/sms', sample_betwext_request
    assert last_response.ok?, "Post failed"
  end


end