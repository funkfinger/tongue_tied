class TongueTiedApp < Sinatra::Base
  post '/api/sms' do
    halt 500, 'API error - necessary params missing' if 
      ( params[:telephony_account_id].nil? || params[:message].nil? || params[:numbers].nil? )
    ta = TelephonyAccount.first(:id => params[:telephony_account_id])
    halt 500, 'API error - bad telephony account' if ta.nil?
    sms = Sms.create(ta.provider)
    sms.send_messages(params[:message], ta.number, params[:numbers])
  end
end