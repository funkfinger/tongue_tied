class OutgoingMessage
  include DataMapper::Resource
  property :id, Serial
  property :message, String, :required => true, :length => 160
  timestamps :at  
  belongs_to :telephony_account
  has n, :subscribers, :through => Resource
end