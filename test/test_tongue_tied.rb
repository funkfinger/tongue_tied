require File.expand_path '../test_helper.rb', __FILE__

class TongueTied < TongueTiedTests

  include Rack::Test::Methods
  
  def tm( params={} )
    TextMessage.create( sample_text_message(params) )
  end
  
  def sample_text_message( params={} )
    def_params={
      "body" => "message"
    }.merge( params )
  end
  
  def sample_twilio_request( params={} )
    def_params={
      "AccountSid"=>"AC50c36451e9ccffe77249b8ca05936b1a", 
      "Body"=>"Hello", 
      "ToZip"=>"85003",
      "FromState"=>"AZ", 
      "ToCity"=>"PHOENIX", 
      "SmsSid"=>"SM44fdf7b79d6d815d70d45df902607d6e", 
      "ToState"=>"AZ", 
      "To"=>"+16024599557", 
      "ToCountry"=>"US", 
      "FromCountry"=>"US", 
      "SmsMessageSid"=>"SM44fdf7b79d6d815d70d45df902607d6e", 
      "ApiVersion"=>"2010-04-01", 
      "FromCity"=>"PHOENIX", 
      "SmsStatus"=>"received", 
      "From"=>"+16023218695", 
      "FromZip"=>"85304"
    }.merge( params )
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
    assert last_response.ok?
  end

  def text_from_twilio( params={} )
    params = sample_twilio_request( params )
    post '/api/twilio/sms', params
    assert last_response.ok?
  end

######## test below are in reverse cronological order....

  def test_add_to_betwext_list_link
    create_betwext
    req = BetwextRequest.first
    get "/api/betwext/add_to_betwext_list/#{req.keyword}/4244/#{req.sender_number}"
    assert last_response.redirect?
  end

  def test_text_message_has_keyword
    text_from_twilio( "Body" => ' keyword 1' )
    tm = TextMessage.first( :keyword => 'keyword' )
    refute tm.nil?, "message should not be nil - #{tm}"
    assert_equal tm.keyword, 'keyword', "keyword should be 'keyword'"
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
    assert_match /\<a href\=\'(.*?)\'\>clickable_key\<\/a\>/, last_response.body, "Can't find clickable keyword"
  end

  def test_list_betwext_keywords
    create_betwext({ :keyword => 'found_me_key' })
    get '/api/betwext/keyword_list'
    assert last_response.ok?
    assert_match /found_me_key/, last_response.body, "Can't find me"
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
    keyword = BetwextKeyword.first( :keyword => 'new_key' )
    refute keyword.nil?
    assert_equal keyword.keyword, 'new_key'
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

  def test_create_tilio_request_doesnt_break_on_bad_param_passed
    db_count = TextMessage.count
    params = sample_twilio_request({:AccountSid => "1", "Body"  => "2", "bad_key" => "3"})
    post '/api/twilio/sms', params
    assert last_response.ok?, "Post failed - params = #{params}"
    assert_equal db_count + 1, TextMessage.count
  end

  def test_twilio_request_requires_raw
    refute TwilioRequest.new({}).save
    assert TwilioRequest.new({ :raw => "blah" }).save
  end

  def test_twilio_request_creates_text_message_entry
    db_count = TextMessage.count
    post '/api/twilio/sms', sample_twilio_request
    assert last_response.ok?
    assert_equal db_count + 1, TextMessage.count
  end

  def test_list_twilio_requests
    r = sample_twilio_request( {:Body => 'found_me'} )
    post '/api/twilio/sms', r
    assert last_response.ok?
    get '/twilio/list'
    assert_match /found\_me/, last_response.body, "Couldn't find me - #{r}"
  end

  def test_twilio_request_without_twilio_sid_returns_500_error
    r = sample_twilio_request.delete :SmsSid
    post '/api/twilio/sms', r
    refute last_response.ok?, "Should have failed without SmsSid"
  end

  def test_twilio_request_creates_twilio_request_database_entry
      db_count = TwilioRequest.count
      post '/api/twilio/sms', sample_twilio_request
      assert last_response.ok?
      assert_equal db_count + 1, TwilioRequest.count
  end

  def test_can_create_twilio_request_entry
    db_count = TwilioRequest.count
    app.process_twilio_request( sample_twilio_request )
    assert_equal db_count + 1, TwilioRequest.find_all.count
  end

  def test_twilio_request
    post '/api/twilio/sms', sample_twilio_request
    assert last_response.ok?, "last response wasn't OK - #{sample_twilio_request.to_s}"
  end

  def test_sms_api_returns_xml_twilio_can_understand
    expected_xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Response>\n  <Sms>created</Sms>\n</Response>\n"
    post '/api/twilio/sms', sample_twilio_request
    assert last_response.ok?
    assert_equal expected_xml, last_response.body
  end

  def test_sms_api_returns_xml_mime_type
    post '/api/twilio/sms', sample_twilio_request
    assert last_response.ok?
    assert_equal 'text/xml;charset=utf-8', last_response.headers['Content-Type']
  end

  def test_sms_api_exists
    post '/api/twilio/sms', sample_twilio_request
    assert last_response.ok?
    assert last_response.ok?
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
  
  def test_twilio_client
    # run using foreman: foreman run bundle exec ruby test/test_tongue_tied.rb
      @twilio_client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
    assert @twilio_client
  end

  def test_root_website_ok
    get '/'
    assert last_response.ok?
  end
end