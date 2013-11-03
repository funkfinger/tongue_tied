class TongueTiedApp < Sinatra::Base

  get '/api/plivo/sms/list' do
    @plivo_list = PlivoRequest.all(:limit => 100)
    haml :plivo_list
  end

  post '/api/plivo/sms' do
    halt 500, 'API error - failed to save' unless PlivoRequest.create_plivo_request(params)
    # removing the xml response because I think we should control the sending of messages elsewhere...
    content_type 'text/xml'
    PlivoRequest.response_xml("Cool, your quiz response was recieved... we'll let you know if you're a winner soon.", params['From'], params['To'])
  end
end
