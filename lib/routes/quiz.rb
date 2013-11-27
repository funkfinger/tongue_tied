class TongueTiedApp < Sinatra::Base


  get '/api/telephony_account/:telephony_account_id/quiz/:quiz_id/quiz_question_responses/:question_id' do
    @ta = TelephonyAccount.get(params[:telephony_account_id])
    halt 500, 'API error - telephony account does not exist' if @ta.nil?
    @q = @ta.quizzes.get(params[:quiz_id])
    halt 500, 'API error - quiz does not exist' if @q.nil?
    @qq = @q.quiz_questions.get(params[:question_id])
    halt 500, 'API error - quiz question does not exist' if @qq.nil?
    haml :quiz_responses
  end

  get '/api/telephony_account/:telephony_account_id/quiz/deactivate_quiz/:quiz_id' do
    ta = TelephonyAccount.get(params[:telephony_account_id])
    halt 500, 'API error - telephony account does not exist' if ta.nil?
    q = ta.get_quiz(params[:quiz_id])
    halt 500, 'API error - failed to save' unless ta.deactivate_quiz(q)
    flash[:success] = 'quiz deactivated'
    redirect "/api/telephony_account_detail/#{ta.id}"
  end

  get '/api/telephony_account/:telephony_account_id/quiz/activate_quiz/:quiz_id' do
    ta = TelephonyAccount.get(params[:telephony_account_id])
    q = ta.get_quiz(params[:quiz_id])
    halt 500, 'API error - failed to save' unless ta.activate_quiz(q)
    flash[:success] = 'quiz activated'
    redirect "/api/telephony_account_detail/#{ta.id}"
  end

  post '/api/telephony_account/:id/quiz/create' do
    ta = TelephonyAccount.get(params[:id])
    halt 500, 'API error - telephony account does not exist' if ta.nil?
    ta.quizzes.new(:name => params[:name], :response_message => params[:response_message])
    halt 500, 'API error - failed to save' unless ta.save
    flash[:success] = 'quiz created'
    redirect "/api/telephony_account_detail/#{ta.id}"
  end

end
