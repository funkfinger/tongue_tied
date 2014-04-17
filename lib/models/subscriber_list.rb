class SubscriberList
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :required => true
  timestamps :at

  has n, :subscribers

  belongs_to :telephony_account

  def self.add_subscriber(subscriber_list_id, subscriber_id)
    subscriber_list = SubscriberList.get(subscriber_list_id)
    subscriber = subscriber_list.telephony_account.subscribers.get(subscriber_id)
    raise 'bad subscriber or subscriber_list id' if subscriber_list.nil? or subscriber.nil?
    subscriber_list.subscribers << subscriber
    raise unless subscriber_list.save
  end

  def self.add_subscribers(subscriber_list_id, subscriber_ids)
    subscriber_ids.each{ |id| self.add_subscriber(subscriber_list_id, id) }
  end



end