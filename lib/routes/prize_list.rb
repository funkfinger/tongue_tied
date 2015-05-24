class TongueTiedApp < Sinatra::Base

  get '/prizes' do
    @pl = PrizeList.all(:limit => 10000)
    haml :prize_list unless @pl.nil?
  end

  get '/prizes/claim/:id' do
    @p = PrizeList.get(params[:id])
    haml :prize_list_claim unless @p.nil?
  end

end
