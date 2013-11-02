require File.expand_path '../test_helper.rb', __FILE__

class TongueTiedQuizTest < TongueTiedTests

  include Rack::Test::Methods

  # def setup
  #   DataMapper.auto_migrate!
  #   @t = TelephonyAccount.new(:number => '1', :provider => 'test_provider')
  # end

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
 
  def test_quiz_can_send_question_to_subscribers
    q = @t.quizzes.new(:name => 'quiz with participants', :response_message => 'response message')
    q.subscribers << @t.subscribers.new(:from_number => '111', :to_number => '222')
    assert q.save
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