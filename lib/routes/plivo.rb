class TongueTiedApp < Sinatra::Base

  get '/api/plivo/sms/list' do
    @plivo_list = PlivoRequest.all(:limit => 100)
    haml :plivo_list
  end

  post '/api/plivo/sms' do
    halt 500, 'API error - failed to save' unless PlivoRequest.create_plivo_request(params)
    content_type 'text/xml'
    PlivoRequest.response_xml("created", params['From'], params['To'])
  end
end
