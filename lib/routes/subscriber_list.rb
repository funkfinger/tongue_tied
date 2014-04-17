class TongueTiedApp < Sinatra::Base

  post '/api/telephony_account/:id/subscriber_list/:subscriber_list_id/add_subs' do
    SubscriberList.add_subscribers(params['subscriber_list_id'], params['subscriber_ids'])
  end

  post '/api/telephony_account/:id/subscriber_list/:subscriber_list_id/add_sub' do
    SubscriberList.add_subscriber(params['subscriber_list_id'], params['subscriber_id'])
  end


end