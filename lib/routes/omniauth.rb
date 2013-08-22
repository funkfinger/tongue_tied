class TongueTiedApp < Sinatra::Base

  get '/auth/:provider/callback' do
    halt 500 unless request.env['omniauth.auth']
    u = User.first_or_create_from_omniauth(request.env['omniauth.auth'])
    halt 500 unless u
    flash[:notice] = "signed in - #{u.uid} | User.count = #{User.count}"
    redirect '/'
  end

  get '/auth/failure' do
  	flash[:notice] = params[:message] # if using sinatra-flash or rack-flash
  	redirect '/'
  end

end
