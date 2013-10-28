require File.expand_path '../test_helper.rb', __FILE__

class TongueTiedQuizTest < TongueTiedTests

  include Rack::Test::Methods

  # def setup
  #   DataMapper.auto_migrate!
  #   @t = TelephonyAccount.new(:number => '1', :provider => 'test_provider')
  # end

  ######## test below are in reverse cronological order....
  
  def test_quiz_can_have_participants
    # q = Quiz.new(:name => 'first quiz')
    # assert_equal 0, q.quiz_participant.count
    # q.quiz_participant.new(Subscriber.new())
    # assert q.save
    # assert_equal 1, q.quiz_participant.count
  end

  def test_quiz_can_have_questions
    q = @t.quizzes.new(:name => 'first quiz')
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
    q = @t.quizzes.new(:name => 'first quiz')
    assert q.save
  end

end