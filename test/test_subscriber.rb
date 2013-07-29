require File.expand_path '../test_helper.rb', __FILE__

class TongueTiedSubscriber < TongueTiedTests

  include Rack::Test::Methods


  def test_stop_keyword_deactivates_subscriber_and_is_case_indifferent
    t = TextMessage.new("body" => "message", "from" => "18005551212", :to => "9999999999")
    assert t.save
    assert t.subscriber.active
    t = tm("body" => "stop")
    refute t.subscriber.active
    t = tm
    assert t.subscriber.active
    t = tm("body" => "sToP")
    refute t.subscriber.active    
  end

end