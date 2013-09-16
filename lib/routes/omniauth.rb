 class TongueTiedApp < Sinatra::Base

  get '/auth/:provider/callback' do
    halt 500 unless request.env['omniauth.auth']
    u = User.first_or_create_from_omniauth(request.env['omniauth.auth'])
    halt 500 unless u
    session[:uid] = u.uid
    flash[:success] = "successfully signed in as #{u.name}"
    redirect '/'
  end

  get '/auth/failure' do
  	flash[:error] = params[:message] # if using sinatra-flash or rack-flash
  	redirect '/'
  end

end
