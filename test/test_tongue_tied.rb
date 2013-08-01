require File.expand_path '../test_helper.rb', __FILE__

class TongueTied < TongueTiedTests
  
  def tm(params = {})
    t = TextMessage.new(sample_text_message(params))
    assert t.save, "failed basic save - #{t.body}"
    return t
  end
  
  def sample_text_message(params = {})
    def_params={
      "body" => "message",
      "from_number" => "18005551212",
      "to_number" => "0000000000"
    }.merge(params)
  end
  
######## test below are in reverse cronological order....



  def test_text_message_has_number
    t = tm({"to_number" => "123456789"})
    assert_equal "123456789", t["to_number"]
  end

  def test_text_message_has_creation_date_and_is_a_date
    refute tm.created_at.nil?
    assert_equal Time.now.day, tm.created_at.day
  end  

  def test_text_message_has_body
    refute tm({:body => 'body text'}).body.nil?
  end  

  def test_create_text_message
    refute tm.nil?
  end

  def test_environment_variables_get_set_in_test_helper
    # run using foreman: foreman run bundle exec ruby test/test_tongue_tied.rb
    assert_equal 'localhost', ENV['DB_HOST']
  end
  
  def test_root_website_ok
    get '/'
    assert last_response.ok?
  end

end