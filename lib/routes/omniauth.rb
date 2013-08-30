 class TongueTiedApp < Sinatra::Base

  get '/auth/:provider/callback' do
    halt 500 unless request.env['omniauth.auth']
    u = User.first_or_create_from_omniauth(request.env['omniauth.auth'])
    halt 500 unless u
    session[:uid] = u.id
    flash[:success] = "signed in - #{u.uid} | User.count = #{User.count} - #{session[:uid]}"
    redirect '/'
  end

  get '/auth/failure' do
  	flash[:error] = params[:message] # if using sinatra-flash or rack-flash
  	redirect '/'
  end

end
