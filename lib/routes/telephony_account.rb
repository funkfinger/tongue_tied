class TongueTiedApp < Sinatra::Base

  get '/api/telephony_account/:id/edit' do
    @ta = get_telephony_account(params[:id])
    haml :telephony_account_edit
  end

  put '/api/telephony_account/:id' do
    ta = get_telephony_account(params[:id])
    ta.number = params[:number]
    ta.response = params[:response]
    ta.save
    flash[:success] = 'telephony account updated'
    redirect "/api/telephony_account_detail/#{ta.id}"
  end

  delete '/api/telephony_account/:id/keyword/:keyword_id' do
    ta = get_telephony_account(params[:id])
    kw = ta.keywords.first(params[:id])
    halt 500, 'API error - keyword does not exist' if kw.nil?
    kw.destroy
    ta.save
    flash[:success] = 'keyword deleted'
    redirect "/api/telephony_account/#{ta.id}/keywords"
  end


  put '/api/telephony_account/:id/keyword/:keyword_id' do
    ta = get_telephony_account(params[:id])
    kw = ta.keywords.first(params[:id])
    halt 500, 'API error - keyword does not exist' if kw.nil?
    kw.word = params[:word]
    kw.response = params[:response]
    ta.save
    flash[:success] = 'keyword updated'
    redirect "/api/telephony_account/#{ta.id}/keywords"
  end

  get '/api/telephony_account/:id/keyword/:keyword_id' do
    @ta = get_telephony_account(params[:id])
    @kw = @ta.keywords.first(:id => params[:keyword_id])
    halt 500, 'API error - keyword does not exist' if @kw.nil?
    haml :telephony_account_edit_keyword
  end

  post '/api/telephony_account/:id/keyword' do
    halt 500, 'API error - missing word parameter' if params[:word].nil?
    halt 500, 'API error - missing response parameter' if params[:response].empty?
    ta = get_telephony_account(params[:id])
    ta.keywords.new(:word => params[:word], :response => params[:response])
    halt 500, 'API error - failed to save' unless ta.save
    flash[:success] = 'keyword added'
    redirect "/api/telephony_account/#{ta.id}/keywords"
  end

  post '/api/telephony_account/:id/subscriber' do
    halt 500, 'API error - missing subscriber parameter' if params[:from_number].nil?
    ta = get_telephony_account(params[:id])
    ta.subscribers.new(:from_number => params[:from_number])
    halt 500, 'API error - failed to save' unless ta.save
    flash[:success] = 'subscriber added'
    redirect "/api/telephony_account/#{ta.id}/subscribers"
  end

  get '/api/telephony_account/:id/keywords' do
    @ta = get_telephony_account(params[:id])
    @telephony_account_keywords = @ta.keywords
    haml :telephony_account_keywords
  end

  get '/api/telephony_account/:id/subscribers' do
    @ta = get_telephony_account(params[:id])
    @telephony_account_subscribers = @ta.subscribers.active_subscribers
    haml :telephony_account_subscribers
  end

  get '/api/telephony_account_detail/:id' do
    @telephony_account = get_telephony_account(params[:id])
    haml :telephony_account_detail
  end

  get '/api/telephony_account/list' do
    @telephony_accounts = TelephonyAccount.all
    haml :telephony_account_list
  end

  get '/api/telephony_account/create' do
    haml :telephony_account_form
  end

  post '/api/telephony_account/create' do
    # halt 500, 'API error - missing provider' if params[:provider].empty?
    ta = TelephonyAccount.first_or_create(:number => params[:number])
    ta.provider = params[:provider]
    halt 500, 'API error - failed to save' unless ta.save
    flash[:success] = 'created'
    redirect '/api/telephony_account/list'
  end
  
end
