require File.expand_path '../test_helper.rb', __FILE__

class TongueTiedSubscriberMessageTest < TongueTiedTests


  def setup
    super
    @to_number = "111"
    @from_number = "222"
    @sub = Subscriber.first_or_create(:from_number => @from_number, :to_number => @to_number)
    assert @sub.save
  end


  def test_subscriber_message_has_creation_date
    m = @sub.subscriber_messages.new(:body => "hello")
    assert m.save
    refute m.created_at.nil?
  end

  def test_subscriber_can_have_message
  	assert @sub.subscriber_messages.new(:body => "first!").save
    m = SubscriberMessage.first(:body => "first!")
    assert m
    assert_equal @from_number, m.subscriber.from_number
  end

end