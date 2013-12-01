class TongueTiedApp < Sinatra::Base

  get '/api/telephony_account_detail/:id' do
    @telephony_account = TelephonyAccount.get(params[:id])
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
