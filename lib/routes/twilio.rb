class TongueTiedApp < Sinatra::Base
  
  get '/api/twilio/list' do
    @sms_list = TwilioRequest.all(:limit => 100)
    haml :twilio_list
  end

  post '/api/twilio/sms' do
    content_type 'text/xml', :charset => 'utf-8'
    halt(500, 'API error - missing SID') if params['SmsSid'].nil?
    if TwilioRequest.create_twilio_request(params)
      TwilioRequest.response_xml("created")
    else
      halt 500, 'API error - unable to save'
    end 
  end

end