require File.expand_path '../test_helper.rb', __FILE__

class TongueTiedApp
  get "/set_flash_for_test" do 
    flash[:notice] = params[:flash]
    "set"
  end
end

class TongueTied < TongueTiedTests
  
  def tm(params = {})
    t = @t.text_messages.new(sample_text_message(params))
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

def test_homepage_uses_bootstrap_from_cdn
  get '/'
  assert last_response.ok?
  assert_match /https\:\/\/maxcdn\.bootstrapcdn\.com\/bootstrap\/3\.3\.4\/css\/bootstrap\.min\.css/, last_response.body  
end

def XXX_deleted_20150502_test_homepage_is_claim_page_for_now
  get '/'
  assert last_response.ok?
  assert_match /claim your prize/, last_response.body
end


  def test_blank
    assert "".blank?
    assert nil.blank?
  end


  def XXX_disabled_20150502_test_layout_has_angular_js
    get '/'
    assert last_response.ok?
    assert_match /angular\.min\.js/, last_response.body
  end

  def XXX_disabled_20150502_test_layout_has_breadcrumb
    get '/'
    assert last_response.ok?
    assert_match /breadcrumb/, last_response.body
  end

  def test_plivo_sms_can_send_multiple_messages
    res = [202, {"api_id"=>"d056586a-42b7-11e3-9033-12314000c5ac", "message"=>"blah", "message_uuid"=>["d07d25a8-42b7-11e3-8c69-123140019572"]}]
    Plivo::RestAPI.any_instance.stubs(:send_message).returns(res)
    sms = Sms.create('plivo')
    sms.stubs(:send_message).times(5)
    sms.send_messages('message', '18005551212', ['1','2','3','4','5'])
  end

  def test_plivo_sms_send_message_responds_with_false_on_error
    res = [400, {"api_id"=>"d056586a-42b7-11e3-9033-12314000c5ac", "message"=>"message(s) queued", "message_uuid"=>["d07d25a8-42b7-11e3-8c69-123140019572"]}]
    Plivo::RestAPI.any_instance.stubs(:send_message).returns(res)
    sms = Sms.create('plivo')
    refute sms.send_message('1', '2', 'text')
  end

  def test_plivo_sms_sends_message
    res = [202, {"api_id"=>"d056586a-42b7-11e3-9033-12314000c5ac", "message"=>"blah", "message_uuid"=>["d07d25a8-42b7-11e3-8c69-123140019572"]}]
    Plivo::RestAPI.any_instance.stubs(:send_message).returns(res)
    sms = Sms.create('plivo')
    assert sms.send_message('1', '2', 'text')
  end

  def test_sms_object_raises_error_on_abstract_class
    sms = Sms.new
    assert_raises RuntimeError do 
      sms.send_message('1', '2', 'text')
    end
  end

  def test_sms_object_returns_twilio_on_create
    sms = Sms.create('twilio')
    assert_equal 'TwilioSms', sms.class.name
  end

  def test_sms_object_returns_plivo_on_create
    sms = Sms.create('plivo')
    assert_equal 'PlivoSms', sms.class.name
  end

  def test_plivo_helper_exists
    assert Plivo
  end

  def test_rack_serves_static_ico_file
    get "/favicon.ico"
    assert last_response.ok?
  end

  # see monkey patch abovve to set flash val...
  def test_flash_messages_work
    get "/"
    refute_match /should show on page/, last_response.body
    get "/set_flash_for_test?flash=should%20show%20on%20page"
    get "/"
    assert_match /should show on page/, last_response.body
    get "/"
    refute_match /should show on page/, last_response.body
  end

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