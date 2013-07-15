require 'data_mapper'

db_connection_string = "postgres://#{ENV['DB_USER']}:#{ENV['DB_PASS']}@#{ENV['DB_HOST']}/#{ENV['DB_NAME']}"
DataMapper.setup(:default, db_connection_string)

# models...
class TextMessage
  include DataMapper::Resource
  property :id, Serial
  property :body, String, :required => true
  property :keyword, String
  timestamps :at
  
  before :save, :make_keyword
  
  def make_keyword
    self.body.match(/^\s*(\S*)/)
    self.keyword = $1
  end
end

class TwilioRequest
  include DataMapper::Resource
  property :id, Serial
  property :raw, Text, :required => true
  property :SmsSid, String
  property :SmsMessageSid, String
  property :SmsStatus, String
  property :AccountSid, String
  property :From, String
  property :To, String
  property :Body, String
  property :SmsSid, String
  property :FromZip, String
  property :ToZip, String
  property :FromState, String
  property :ToState, String
  property :FromCity, String
  property :ToCity, String
  property :FromCountry, String
  property :ToCountry, String
  property :ApiVersion, String
  timestamps :at
  # self.all({:raw => nil}).destroy!
end

class BetwextRequest
  include DataMapper::Resource
  property :id, Serial
  property :raw, Text, :required => true
  property :message_id, String
  property :sender_number, String, :required => true
  property :recipient_number, String
  property :message, String, :required => true
  property :time_received, String
  property :keyword, String, :required => true
  timestamps :at
  has n, :betwext_winners
end

class BetwextWinner
  include DataMapper::Resource
  property :id, Serial
  property :betwext_list_id, Integer
  belongs_to :betwext_request  
end

class BetwextKeyword
  include DataMapper::Resource
  property :id, Serial
  property :keyword, String, :required => true
end

class PlivoRequest
  include DataMapper::Resource
  property :id, Serial
  property :raw, Text, :required => true
  property :plivo_message_id, String
  property :to, String
  property :from, String
  property :text, String, :length => 256
  timestamps :at  
end

# DataMapper.auto_migrate!
DataMapper.auto_upgrade!
