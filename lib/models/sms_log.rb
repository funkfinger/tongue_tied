class SmsLog
  
  include DataMapper::Resource
  property :id, Serial
  property :body, String, :required => true, :length => 160
  property :to_number, String, :required => true
  timestamps :at

  belongs_to :telephony_account

end