require File.expand_path '../test_helper.rb', __FILE__

class TongueTiedQuizTest < TongueTiedTests

  include Rack::Test::Methods

  def setup
    res = [202, {"api_id"=>"d056586a-42b7-11e3-9033-12314000c5ac", "message"=>"blah", "message_uuid"=>["d07d25a8-42b7-11e3-8c69-123140019572"]}]
    Plivo::RestAPI.any_instance.stubs(:send_message).returns(res)
    super
  end

  ######## test below are in reverse cronological order....
  
  def test_quiz_has_response_message
    q = @t.quizzes.new(:name => 'quiz with message', :response_message => 'response message')
    assert q.save
  end


  def test_quiz_can_have_participants
    # q = Quiz.new(:name => 'first quiz')
    # assert_equal 0, q.quiz_participant.count
    # q.quiz_participant.new(Subscriber.new())
    # assert q.save
    # assert_equal 1, q.quiz_participant.count
  end

  # def test_only_one_quiz_is_active_at_a_time
  #   q = @t.quizzes.new(:name => 'first quiz')
  #   assert q.save
  #   q = @t.quizzes.new(:name => 'second quiz')
  #   assert q.save
  #   assert_equal 2, @t.quizzes.count
  #   assert_equal 1, @t.quizzes.all(:active => true).count
  # end

  def test_can_deactivate_quiz_via_web
    q = @t.quizzes.new(:name => 'inactive quiz', :response_message => 'response message')
    assert q.save
    refute q.active
    @t.activate_quiz(q)
    assert q.active
    get "/api/telephony_account/#{@t.id}/quiz/deactivate_quiz/#{q.id}"
    follow_redirect!
    assert last_response.ok?, last_response.inspect
    q = @t.quizzes.get(q.id)
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
    @t.provider = 'plivo'
    @t.save
    q = @t.quizzes.new(:name => 'quiz with participants', :response_message => 'response message')
    q.subscribers << @t.subscribers.new(:from_number => '111', :to_number => '222')
    q.subscribers << @t.subscribers.new(:from_number => '112', :to_number => '222')
    q.quiz_questions.new(:body => 'first question')
    assert q.save
    sms = Sms.create('plivo')
    PlivoSms.any_instance.stubs(:send_message).times(2)
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