require File.expand_path '../test_helper.rb', __FILE__

class TongueTiedTelephonyAccountTest < TongueTiedTests

  include Rack::Test::Methods

  def test_telephony_account_can_have_quiz
    assert_equal 0, Quiz.count
    t = TelephonyAccount.new(:number => '8005551212', :provider => 'plivo')
    t.quizzes.new(:name => 'test quiz')
    assert t.save
    assert_equal 1, Quiz.count
  end


  def test_telephony_account_exists
    t = TelephonyAccount.new(:number => '8005551212', :provider => 'plivo')
    assert t.save
  end

end