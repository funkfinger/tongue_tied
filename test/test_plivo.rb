require File.expand_path '../test_helper.rb', __FILE__

class TongueTiedPlivo < TongueTiedTests

  include Rack::Test::Methods

  def sample_plivo_params( params = {} )
    def_params = {
      "MessageUUID" => "message_uuid",
      "To" => "1",
      "From" => "18005551212",
      "Text" => "sample text"
    }.merge( params )
  end

  def create_plivo( params = {} )
    post '/api/plivo/sms', sample_plivo_params( params )
    assert last_response.ok?, "Post failed - #{last_response.body}"
  end

  ######## test below are in reverse cronological order....
  
  def test_plivo_creates_text_message
    current_count = TextMessage.count
    create_plivo({"Text" => "test text message"})
    assert_equal current_count + 1, TextMessage.count
  end
  
  def test_plivo_with_longer_message
    create_plivo({"Text" => "0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789"})
  end

  # commented out because I think an automatic response isn't the right thing to do at this time...  
  # def test_plivo_response_xml_has_correct_content_type
  #   create_plivo
  #   assert_equal "text/xml;charset=utf-8", last_response.content_type
  # end
  
  # commented out because I think an automatic response isn't the right thing to do at this time...  
  # def test_plivo_responds_with_xml
  #   expected_xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Response>\n  <Message src=\"1\" dst=\"18005551212\">created</Message>\n</Response>\n"
  #   create_plivo
  #   assert_equal expected_xml, last_response.body, "XML not correct"
  # end
  
  def test_plivo_has_the_right_fields
    create_plivo({
      "MessageUUID" => "12345",
      "To" => "1",
      "From" => "23334445555",
      "Text" => 'this is some text find me and more text'
    })
    pr = PlivoRequest.first
    assert_equal pr.plivo_message_id, "12345"
    assert_equal pr.to, "1"
    assert_equal pr.from, "23334445555"
    assert_match /find me/, pr.text 
  end
  
  def test_plivo_can_list_raw_requests
    create_plivo( {"Text" => 'this is some text find me and more text'} )
    get '/api/plivo/sms/list'
    assert last_response.ok?
    pr = PlivoRequest.first()
    assert_match /find me/, pr.raw, "Find text not found"
  end
  
  def test_plivo_api_saves_raw_request
    create_plivo( {"Text" => 'this is some text find me and more text'} )
    pr = PlivoRequest.first()
    assert_match /find me/, pr.raw, "Can't find me"
  end
  
  def test_plivo_api_saves_request
    count = PlivoRequest.count
    create_plivo( {"Text" => 'this is some text find me and more text'} )
    assert_equal count + 1, PlivoRequest.count, "Didn't create record"
  end
  
  def test_plivo_endpoint_exists
    create_plivo( {"Text" => 'this is some text find me and more text'} )
    assert last_response.ok?, "Post failed"
  end

end 