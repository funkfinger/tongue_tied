class TongueTiedApp < Sinatra::Base
  
  get '/users' do
    @users = User.all(:limit => 100)
    haml :users
  end

  get '/user/:id' do
    @user = User.first(:id => params[:id])
    haml :user
  end

end