require File.expand_path '../test_helper.rb', __FILE__

class TongueTiedQuizTest < TongueTiedTests

  include Rack::Test::Methods


  ######## test below are in reverse cronological order....
  
  def test_quiz_can_have_participants
    # q = Quiz.new(:name => 'first quiz')
    # assert_equal 0, q.quiz_participant.count
    # q.quiz_participant.new(Subscriber.new())
    # assert q.save
    # assert_equal 1, q.quiz_participant.count
  end

  def test_quiz_can_have_questions
    q = Quiz.new(:name => 'first quiz')
    assert_equal 0, q.quiz_questions.count
    q.quiz_questions.new(:body => 'first question')
    assert q.save
    assert_equal 1, q.quiz_questions.count
  end

  def test_quiz_name_is_required
    q = Quiz.new()
    refute q.save
  end

  def test_quiz_model_exists
    q = Quiz.new(:name => 'first quiz')
    assert q.save
  end

end