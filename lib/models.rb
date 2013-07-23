require 'data_mapper'

db_connection_string = "postgres://#{ENV['DB_USER']}:#{ENV['DB_PASS']}@#{ENV['DB_HOST']}/#{ENV['DB_NAME']}"
DataMapper.setup(:default, db_connection_string)

# models...

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
  property :text, String, :length => 160
  timestamps :at  
end

class Subscriber
  include DataMapper::Resource
  property :id, Serial
  property :number, Text, :required => true
  property :active, Boolean, :default => true
  belongs_to :text_message
end

class Campaign
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :required => true, :length => 160
  property :keyword, String, :required => true, :length => 160
  
  before :save, :upcase_keyword
  # has 1, :keyword
  
  def upcase_keyword
    self.keyword.upcase!
  end
  
end

class Keyword
  include DataMapper::Resource
  property :id, Serial
  property :word, String, :required => true, :length => 160

  before :save, :upcase_word

  # belongs_to :campaign
  belongs_to :text_message

  def upcase_word
    self.word.upcase!
  end

end


# DataMapper.auto_migrate!
DataMapper.finalize
DataMapper.auto_upgrade!
