require File.expand_path '../test_helper.rb', __FILE__

class TongueTiedSubscriber < TongueTiedTests

  def create_subscriber_list
    sl = @t.subscriber_lists.new(:name => 'test sub list')
    @s1 = @t.subscribers.new(:from_number => '1')
    @s2 = @t.subscribers.new(:from_number => '2')
    assert @t.save
    sl
  end

  def test_can_add_multiple_subscribers_via_api
    sl = create_subscriber_list
    assert_equal 0, sl.subscribers.count
    post "/api/telephony_account/#{sl.telephony_account.id}/subscriber_list/#{sl.id}/add_subs", {:subscriber_ids => [@s1.id, @s2.id]}
    assert last_response.ok?
    assert_equal 2, sl.subscribers.count
  end

  def test_can_add_subscriber_via_api
    sl = create_subscriber_list
    assert_equal 0, sl.subscribers.count
    post "/api/telephony_account/#{sl.telephony_account.id}/subscriber_list/#{sl.id}/add_sub", {:subscriber_id => @s1.id}
    # post "/api/telephony_account/#{sl.telephony_account.id}/subscriber_list/#{sl.id}", {:subscriber => 999}
    assert last_response.ok?
    assert_equal 1, sl.subscribers.count
  end

  def test_subscriber_list_can_have_subscribers
    sl = create_subscriber_list
    assert_equal 0, sl.subscribers.count
    sl.subscribers << @s1
    assert sl.save
    assert_equal 1, sl.subscribers.count
  end

  def test_sanity
    assert true
  end

end