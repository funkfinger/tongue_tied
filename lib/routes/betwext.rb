class TongueTiedApp < Sinatra::Base

  get '/api/betwext/sms' do
    'not a 404'
  end

  post '/api/betwext/sms' do
    halt(500, 'API error - no params') if params.nil?
    br_exists = BetwextRequest.first(:sender_number => params['sender_number'], :keyword => params['keyword'])
    halt(200, 'exists') if br_exists
    br = BetwextRequest.new({
      :raw => params.to_s,
      :message_id => params['message_id'],
      :sender_number => params['sender_number'],
      :recipient_number => params['recipient_number'],
      :message => params['message'],
      :time_received => params['time_received'],
      :keyword => params['keyword']
    })
    halt(500, 'API error - can\'t save request') if !br.save
    # keyword = BetwextKeyword.first_or_create({ :keyword => params['keyword'] })
    # halt(500, 'API error - can\'t save keyword') if !keyword.save
    'created'
  end
  
  get '/api/betwext/list' do
    @betwext_list = BetwextRequest.all(:limit => 100)
    haml :betwext_list
  end
  
  get '/api/betwext/keyword_list' do
    # @betwext_keyword_list = BetwextKeyword.all(:limit => 100, :unique => true)
    @betwext_keyword_list = BetwextKeyword.all(:fields => [:id, :keyword], :limit => 1000, :unique => true, :order => [:id.desc])
    @betwext_keyword_list = BetwextKeyword.all(:limit => 1000, :order => [:id.desc])
    haml :betwext_keyword_list
  end
  
  get '/api/betwext/keyword/:keyword' do
    @betwext_entries = BetwextRequest.all(:keyword => params[:keyword])
    haml :betwext_keyword_number_list
  end
  
  get '/api/betwext/add_to_betwext_list/:keyword/:list/:number' do
    halt(500, 'Error posting to Betwext') unless post_to_betwext(params[:number], params[:list])
    br = BetwextRequest.first(:sender_number => params[:number], :keyword => params[:keyword])
    if br.betwext_winners.first(:betwext_list_id => params[:list]).nil?
      br.betwext_winners.new(:betwext_list_id => params[:list])
      halt(500, 'Error creating list entry') unless br.save
    end
    redirect "/api/betwext/keyword/#{params[:keyword]}"
  end

end