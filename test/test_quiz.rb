require File.expand_path '../test_helper.rb', __FILE__

class TongueTiedQuizTest < TongueTiedTests

  include Rack::Test::Methods

  def setup
    TestProviderSms.any_instance.unstub(:send_message)
    super
  end

  # def setup(*res)
  #   res = res.nil? ? [202, {"api_id"=>"1", "message"=>"blah", "message_uuid"=>["2"]}] : res
  #   Plivo::RestAPI.any_instance.stubs(:send_message).returns(res)
  #   super
  # end

  ######## test below are in reverse cronological order....


  def test_quiz_can_send_question_to_only_active_subscribers
    q = @t.quizzes.new(:name => 'quiz with participants', :response_message => 'response message')
    assert q.save
    @t.activate_quiz(q)
    @t.text_messages.new("body" => "quiz", "from_number" => "111", :to_number => "222").save
    @t.text_messages.new("body" => "quiz", "from_number" => "333", :to_number => "222").save
    @t.text_messages.new("body" => "quiz", "from_number" => "444", :to_number => "222").save
    @t.text_messages.new("body" => "stop", "from_number" => "111", :to_number => "222").save
    @t.text_messages.new("body" => "stop", "from_number" => "333", :to_number => "222").save
    assert q.save
    sms = Sms.create('test_provider')
    TestProviderSms.any_instance.stubs(:send_message).once
    q.send_active_question
  end

  
  def test_sanity_check_that_quiz_subscribers_are_separate_from_telephony_account_subscribers
    q = @t.quizzes.new(:name => 'inactive quiz', :response_message => 'response message')
    assert q.save
    @t.activate_quiz(q)
    @t.text_messages.new("body" => "quiz", "from_number" => "111", :to_number => "222").save
    @t.text_messages.new("body" => "quiz", "from_number" => "333", :to_number => "222").save
    @t.text_messages.new("body" => "quiz", "from_number" => "444", :to_number => "222").save
    @t.text_messages.new("body" => "noquiz", "from_number" => "555", :to_number => "222").save
    q.reload
    assert_equal 3, q.subscribers.count, "q.subscribers = #{q.subscribers.inspect}"
    assert_equal 4, @t.subscribers.count
  end

  def test_quiz_has_response_message
    q = @t.quizzes.new(:name => 'quiz with message', :response_message => 'response message')
    assert q.save
  end

  def test_new_enrollment_via_text_is_only_for_active_quiz
    q = @t.quizzes.new(:name => 'inactive quiz', :response_message => 'response message')
    assert q.save
    refute q.active
    assert_equal 0, q.subscribers.count
    t = @t.text_messages.new("body" => "quiz", "from_number" => "111", :to_number => "222")
    assert t.save
    q.reload
    assert_equal 0, q.subscribers.count
    @t.activate_quiz(q)
    t = @t.text_messages.new("body" => "quiz", "from_number" => "111", :to_number => "222")
    assert t.save
    q.reload
    assert_equal 1, q.subscribers.count, "q.subscribers = #{q.subscribers.inspect}"
  end

  def test_can_enroll_in_quiz_via_api
    q = @t.quizzes.new(:name => 'enroll in quiz via api', :response_message => 'response message')
    assert q.save
    @t.activate_quiz(q)
    assert_equal 0, q.subscribers.count
    post '/api/plivo/sms', {'MessageUUID' => 1, 'To' => @t.number, 'From' => '2', 'Text' => 'quiz'}
    assert last_response.ok?
    assert_equal 1, q.subscribers.count
  end

  def test_can_enroll_in_quiz_via_text_message
    q = @t.quizzes.new(:name => 'enroll in quiz', :response_message => 'response message')
    assert q.save
    @t.activate_quiz(q)
    assert @t.save
    assert_equal 0, q.subscribers.count
    t = @t.text_messages.new("body" => "quiz", "from_number" => "111", :to_number => "222")
    assert t.save
    q.reload
    assert_equal 1, q.subscribers.count, @t.quizzes.first.subscribers.inspect
    t = @t.text_messages.new("body" => "quiz", "from_number" => "333", :to_number => "222")
    assert t.save
    q.reload
    assert_equal 2, q.subscribers.count
  end

  def test_only_one_quiz_is_active_at_a_time
    q = @t.quizzes.new(:name => 'first quiz', :response_message => 'response message')
    assert q.save
    @t.activate_quiz(q)
    q = @t.quizzes.new(:name => 'second quiz', :response_message => 'response message')
    assert q.save
    @t.activate_quiz(q)
    assert_equal 2, @t.quizzes.count
    assert_equal 1, @t.quizzes.all(:active => true).count
  end

  def test_throw_error_if_quiz_you_deativate_does_not_exist
    q = Quiz.new(:name => 'throw error if does not exist', :response_message => 'response message')
    assert_raises RuntimeError do 
      @t.deactivate_quiz(q)
    end
  end

  def test_can_deactivate_quiz_via_web
    q = @t.quizzes.new(:name => 'deactive quiz via web', :response_message => 'response message')
    assert q.save
    refute q.active
    @t.activate_quiz(q)
    assert q.active
    get "/api/telephony_account/#{@t.id}/quiz/deactivate_quiz/#{q.id}"
    follow_redirect!
    assert last_response.ok?, last_response.inspect
    q.reload
    refute q.active, q.inspect
  end

  def test_can_deactivate_quiz
    q = @t.quizzes.new(:name => 'inactive quiz', :response_message => 'response message')
    assert q.save
    refute q.active
    @t.activate_quiz(q)
    assert q.active
    @t.deactivate_quiz(q)
    refute q.active
  end

  def test_can_activate_quiz_via_web
    q = @t.quizzes.new(:name => 'inactive quiz', :response_message => 'response message')
    q.save
    refute q.active
    get "/api/telephony_account/#{@t.id}/quiz/activate_quiz/#{q.id}"
    follow_redirect!
    assert last_response.ok?, last_response.inspect
    q.reload
    assert q.active
  end

  def test_can_activate_quiz
    q = @t.quizzes.new(:name => 'inactive quiz', :response_message => 'response message')
    assert q.save
    refute q.active
    @t.activate_quiz(q)
    assert q.active
  end

  def test_quiz_can_set_active_question
    q = @t.quizzes.new(:name => 'quiz with participants', :response_message => 'response message')
    quest = q.quiz_questions.new(:body => 'first question')
    assert q.save
    q.set_active_question(quest)
    assert_equal q.active_question.body, 'first question'
  end

  def test_quiz_has_one_active_question
    q = @t.quizzes.new(:name => 'quiz with participants', :response_message => 'response message')
    quest = q.quiz_questions.new(:body => 'first question')
    q.quiz_questions.new(:body => 'second question')
    q.quiz_questions.new(:body => 'third question')
    assert q.save
    q.set_active_question(quest)
    assert_equal q.active_question.body, 'first question'
  end

  def test_quiz_can_send_question_to_subscribers
    q = @t.quizzes.new(:name => 'quiz with participants', :response_message => 'response message')
    q.subscribers << @t.subscribers.new(:from_number => '111', :to_number => '222')
    q.subscribers << @t.subscribers.new(:from_number => '112', :to_number => '222')
    q.quiz_questions.new(:body => 'first question')
    assert q.save
    sms = Sms.create('test_provider')
    TestProviderSms.any_instance.stubs(:send_message).times(2)
    q.send_active_question
  end

  def test_quiz_can_have_subscribers
    q = @t.quizzes.new(:name => 'quiz with participants', :response_message => 'response message')
    assert_equal 0, q.subscribers.count
    s = @t.subscribers.new(:from_number => '111', :to_number => '222')
    q.subscribers << s
    assert q.save
    assert_equal 1, q.subscribers.count
  end

  def test_quiz_can_be_active
    q = @t.quizzes.new(:name => 'first quiz', :response_message => 'response message')
    q.active = true
    assert q.save
    assert q.active
  end

  def test_quiz_can_be_created_via_post
    assert_equal 0, @t.quizzes.count
    post "/api/telephony_account/#{@t.id}/quiz/create", {:name => 'test create quiz from post', :response_message => 'response message'}
    assert last_response.redirect?
    follow_redirect!
    assert last_response.ok?
    assert_equal 1, @t.quizzes.count
    assert_equal 'test create quiz from post', @t.quizzes.first.name
  end

  def test_quiz_can_have_questions
    q = @t.quizzes.new(:name => 'first quiz', :response_message => 'response message')
    assert_equal 0, q.quiz_questions.count
    q.quiz_questions.new(:body => 'first question')
    assert q.save
    assert_equal 1, q.quiz_questions.count
  end

  def test_quiz_name_is_required
    q = @t.quizzes.new()
    refute q.save
  end

  def test_quiz_model_exists
    q = @t.quizzes.new(:name => 'first quiz', :response_message => 'response message')
    assert q.save
  end

end