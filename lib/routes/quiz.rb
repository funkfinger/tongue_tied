class TongueTiedApp < Sinatra::Base

  post '/api/telephony_account/:id/quiz/create' do
    ta = TelephonyAccount.get(params[:id])
    halt 500, 'API error - telephony account does not exist' if ta.nil?
    ta.quizzes.new(:name => params[:name], :response_message => params[:response_message])
    halt 500, 'API error - failed to save' unless ta.save
    flash[:success] = 'created'
    redirect "/api/telephony_account_detail/#{ta.id}"
  end

end
