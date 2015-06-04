class OutgoingMessage
  include DataMapper::Resource
  property :id, Serial
  property :message, String, :required => true, :length => 160
  property :sent, Boolean, :required => true, :default => false
  
  timestamps :at  
  belongs_to :telephony_account
  has n, :subscribers, :through => Resource
  
  def send_message_to_subscriber(subscriber, message)
    sms = Sms.create(self.telephony_account.provider)
    sms.send_message(self.telephony_account.number, subscriber.from_number, message)
  end
  
  def send_message_to_all_subscribers(message)
    self.subscribers.each do |sub|
      send_message_to_subscriber(sub, message)
    end
  end
  
end