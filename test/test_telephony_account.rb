require File.expand_path '../test_helper.rb', __FILE__

class TongueTiedTelephonyAccountTest < TongueTiedTests

  include Rack::Test::Methods

  def create_account
    t = TelephonyAccount.new(:number => '18889990000', :provider => 'test_provider', :response => 'booyeah')
    assert t.save
    return t
  end

  def test_telephony_account_can_have_subscriber_lists
    t = create_account
    assert_equal 0, t.subscriber_lists.count
    t.subscriber_lists.new(:name =>'new list')
    assert t.save
    assert_equal 1, t.subscriber_lists.count
  end

  def test_telephony_account_edit_page_exists
    get "/api/telephony_account/#{@t.id}/edit"
    assert last_response.ok?, last_response.status
  end

  def test_edit_link_exists_on_telephony_account_detail_page
    get "/api/telephony_account_detail/#{@t.id}"
    assert_match /edit telephony account/, last_response.body
  end

  def test_can_edit_telephony_account_via_api
    put "/api/telephony_account/#{@t.id}", { :number => '1', :provider => 'test_provider', :response => 'res' }
    follow_redirect!
    assert last_response.ok?
    t = TelephonyAccount.get(@t.id)
    assert_equal '1', t.number
    assert_equal 'res', t.response
  end

  def test_text_message_to_telephony_account_does_not_sends_generic_text_message_if_response_is_empty
    TestProviderSms.any_instance.stubs(:send_message).never
    t = create_account
    t.response = ""
    assert t.save
    t.text_messages.new(:body => "generic", :to_number => t.number, :from_number => "2222222222")
    assert t.save
  end


  def test_text_message_to_telephony_account_sends_generic_text_message_response
    TestProviderSms.any_instance.stubs(:send_message).once.with('18889990000', '123', 'booyeah')
    t = create_account
    t.text_messages.new(:body => "generic", :to_number => t.number, :from_number => "123")
    assert t.save
  end


  def test_telephony_account_has_generic_text_message_response
    t = create_account
    t.response = "welcome one and all"
    assert t.save
  end

  def test_telephony_account_detail_page_has_keywords_list_link
    t = create_account
    get "/api/telephony_account_detail/#{t.id}"
    assert_match "list keywords", last_response.body
  end

  def test_telephony_account_has_keywords
    t = create_account
    count = t.keywords.count
    t.keywords.new(:word => 'test_keyword', :response => 'response')
    assert t.save
    assert_equal count + 1, t.keywords.count
  end

  def test_add_subscribers_api_redirects_on_success
    t = create_account
    post "/api/telephony_account/#{t.id}/subscriber", {:from_number => '111'}
    follow_redirect!
    assert last_response.ok?
    assert_equal "/api/telephony_account/#{t.id}/subscribers", last_request.path
  end

  def test_add_subscriber_via_api_halts_500_if_bad_telephony_account_id
    t = create_account
    post "/api/telephony_account/999/subscriber", {:from_number => '111'}
    refute last_response.ok?
  end

  def test_add_subscriber_via_api_halts_500_on_bad_data
    t = create_account
    post "/api/telephony_account/#{t.id}/subscriber"
    refute last_response.ok?
  end

  def test_add_subscriber_via_api_exists
    t = create_account
    post "/api/telephony_account/#{t.id}/subscriber", {:from_number => '111'}
    follow_redirect!
    assert last_response.ok?
  end


  def test_can_add_subscriber_via_api
    t = create_account
    subscriber_count = t.subscribers.count
    post "/api/telephony_account/#{t.id}/subscriber", {:from_number => '111'}
    follow_redirect!
    assert last_response.ok?
    t.reload
    assert_equal subscriber_count + 1, t.subscribers.count
  end


  def test_detail_page_has_list_subscribers_link
    t = create_account
    get "/api/telephony_account_detail/#{t.id}"
    assert_match "list subscribers", last_response.body
  end

  def test_raises_error_if_no_active_quiz
    t = create_account
    q1 = t.quizzes.new(:name => 'first quiz', :response_message => 'response message')
    assert t.save
    assert_equal 0, t.quizzes.all(:active => true).count
    assert_raises RuntimeError do 
      t.get_active_quiz
    end
  end

  def test_raises_error_if_more_than_active_quiz
    t = create_account
    q1 = t.quizzes.new(:name => 'first quiz', :response_message => 'response message')
    q2 = t.quizzes.new(:name => 'second quiz', :response_message => 'response message')
    t.save
    t.quizzes.update!(:active => true)
    assert_equal 2, t.quizzes.all(:active => true).count
    assert_raises RuntimeError do 
      t.get_active_quiz
    end
  end

  def test_can_get_active_quiz
    t = create_account
    q = t.quizzes.new(:name => 'first quiz', :response_message => 'response message')
    q.active = true
    t.save
    assert_equal 'first quiz', t.get_active_quiz.name
  end

  def test_telephony_account_detail_page_has_activate_quiz_link
    t = create_account
    get "/api/telephony_account_detail/#{t.id}"
    refute_match "activate_quiz", last_response.body    
    t.quizzes.new(:name => 'sample quiz', :response_message => 'response message')
    assert t.save
    get "/api/telephony_account_detail/#{t.id}"
    assert_match "activate_quiz", last_response.body    
  end

  def test_telephony_account_detail_page_has_add_quiz_button
    t = create_account
    t.quizzes.new(:name => 'sample quiz', :response_message => 'response message')
    assert t.save
    get "/api/telephony_account_detail/#{t.id}"
    assert_match "<button class='btn' type='submit' value='Submit'>create quiz</button>", last_response.body    
  end

  def test_telephony_account_list_page_has_link_to_detail_page
    t = create_account
    get '/api/telephony_account/list'
    assert last_response.ok?
    assert_match "href='/api/telephony_account_detail/#{t.id}'", last_response.body
  end

  def test_telephony_account_detail_page_contains_quizzes
    t = create_account
    get "/api/telephony_account_detail/#{t.id}"
    refute_match /sample quiz/, last_response.body    
    t.quizzes.new(:name => 'sample quiz', :response_message => 'response message')
    assert t.save
    get "/api/telephony_account_detail/#{t.id}"
    assert_match /sample quiz/, last_response.body    
  end

  def test_telephony_account_detail_page_contains_provider
    t = create_account
    get "/api/telephony_account_detail/#{t.id}"
    assert_match t.provider, last_response.body
  end


  def test_telephony_account_detail_page_exists
    t = create_account
    get "/api/telephony_account_detail/#{t.id}"
    assert last_response.ok?
    assert_match t.number, last_response.body
  end

  def test_telephony_create_form_exists
    get '/api/telephony_account/create'
    assert last_response.ok?
  end

  def test_can_list_telephony_accounts
    get '/api/telephony_account/list'
    assert last_response.ok?
    refute_match /8889990000/, last_response.body
    t = TelephonyAccount.new(:number => '8889990000', :provider => 'test_provider')
    assert t.save
    get '/api/telephony_account/list'
    assert last_response.ok?
    assert_match /8889990000/, last_response.body
  end

  def test_telephony_account_can_update_provider
    post '/api/telephony_account/create', {:number => '18005551212', :provider => 'plivo'}
    assert last_response.redirect?
    assert_equal 'plivo', TelephonyAccount.first(:number => '18005551212').provider
    post '/api/telephony_account/create', {:number => '18005551212', :provider => 'twilio'}
    assert_equal 'twilio', TelephonyAccount.first(:number => '18005551212').provider
  end

  def test_multiple_creates_with_same_number_doesnt_create_multiple_telephony_accounts
    count = TelephonyAccount.count
    post '/api/telephony_account/create', {:number => '18005551212', :provider => 'plivo'}
    assert last_response.redirect?
    post '/api/telephony_account/create', {:number => '18005551212', :provider => 'plivo'}
    assert last_response.redirect?
    assert_equal count + 1, TelephonyAccount.count
  end


  def test_can_add_telephony_account_via_webpage
    count = TelephonyAccount.count
    post '/api/telephony_account/create', {:number => '18005551212', :provider => 'plivo'}
    assert last_response.redirect?
    follow_redirect!
    assert last_response.ok?
    assert_equal count + 1, TelephonyAccount.count
  end

  def test_telephony_account_can_have_text_messages
    assert_equal 0, TextMessage.count
    t = TelephonyAccount.new(:number => '8005551212', :provider => 'test_provider')
    t.text_messages.new(:to_number => '1', :from_number => '2', :body => "body")
    assert t.save
    assert_equal 1, TextMessage.count
  end

  def test_telephony_account_can_have_quiz
    assert_equal 0, Quiz.count
    t = TelephonyAccount.new(:number => '8005551212', :provider => 'test_provider')
    t.quizzes.new(:name => 'test quiz', :response_message => 'response message')
    assert t.save
    assert_equal 1, Quiz.count
  end

  def test_telephony_account_exists
    t = TelephonyAccount.new(:number => '8005551212', :provider => 'test_provider')
    assert t.save
  end

end