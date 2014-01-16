require File.expand_path '../test_helper.rb', __FILE__

class TongueTiedTelephonyAccountTest < TongueTiedTests

  include Rack::Test::Methods

  def create_account
    t = TelephonyAccount.new(:number => '18889990000', :provider => 'test_provider')
    assert t.save
    return t
  end

  def test_subscribers_list_page_exists_and_contains_subscribers
    t = create_account
    t.subscribers.new(:to_number => t.number, :from_number => '911')
    t.save
    get "/api/telephony_account/#{t.id}/subscribers"
    assert last_response.ok?
    assert_match "911", last_response.body
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