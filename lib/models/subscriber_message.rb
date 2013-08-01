class SubscriberMessage
  include DataMapper::Resource
  property :id, Serial
  property :body, String, :required => true, :length => 160
  timestamps :at
  
  belongs_to :subscriber
end
