class TongueTiedApp < Sinatra::Base

  get '/auth/:provider/callback' do
    "authenticated (for now) - <br /><br /> #{request.env['omniauth.auth']}"
  end

  get '/auth/failure' do
  	flash[:notice] = params[:message] # if using sinatra-flash or rack-flash
  	redirect '/'
  end

end
