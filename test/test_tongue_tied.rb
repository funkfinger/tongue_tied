require File.expand_path '../test_helper.rb', __FILE__

class TongueTied < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  def app
    TongueTiedApp.new!
  end
  
  def tm(params={})
    TextMessage.create(params)
  end
  
  def sample_twilio_request( params={} )
    def_params={
      :SmsSid => '1234567890123456789012345678901234',
      :AccountSid => '1234567890123456789012345678901234',
      :From => '16025551212',
      :To => '16025551212',
      :Body => 'this is a sample body'
    }.merge( params )
  end

######## test below are in reverse cronological order....

  def test_list_twilio_requests
    r = sample_twilio_request( {:Body => 'found_me'} )
    post '/api/sms', r
    get '/twilio/list'
    assert_match /found\_me/, last_response.body, "Couldn't find me - #{r}"
  end

  def test_twilio_request_without_twilio_sid_returns_500_error
    sample_twilio_request.delete :SmsSid
    post '/api/sms', ":SmsSid exists in params hash"
    refute last_response.ok?, "Should have failed without SmsSid"
  end

  def test_twilio_request_creates_twilio_request_database_entry
      db_count = TwilioRequest.count
      post '/api/sms', sample_twilio_request
      assert_equal db_count + 1, TwilioRequest.find_all.count
  end

  def test_can_create_twilio_request_entry
    db_count = TwilioRequest.count
    app.process_twilio_request( sample_twilio_request )
    assert_equal db_count + 1, TwilioRequest.find_all.count
  end

  def test_twilio_request
    post '/api/sms', sample_twilio_request
    assert last_response.ok?, "last response wasn't OK - #{sample_twilio_request.to_s}"
  end

  def test_sms_api_returns_xml_twilio_can_understand
    expected_xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Response>\n  <Sms>text message response</Sms>\n</Response>\n"
    post '/api/sms', sample_twilio_request
    assert_equal expected_xml, last_response.body
  end

  def test_sms_api_returns_xml_mime_type
    post '/api/sms'
    assert_equal 'text/xml;charset=utf-8', last_response.headers['Content-Type']
  end

  def test_sms_api_exists
    post '/api/sms', sample_twilio_request
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