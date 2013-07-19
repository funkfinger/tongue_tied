require 'data_mapper'

db_connection_string = "postgres://#{ENV['DB_USER']}:#{ENV['DB_PASS']}@#{ENV['DB_HOST']}/#{ENV['DB_NAME']}"
DataMapper.setup(:default, db_connection_string)

# models...
class TextMessage
  include DataMapper::Resource
  property :id, Serial
  property :body, String, :required => true, :length => 160
  # property :keyword, String, :length => 160
  property :number, String, :required => true
  timestamps :at
  
  before :save, :make_keyword
  before :save, :create_subscriber
  before :save, :process_system_keywords
  
  has 1, :subscriber
  has 1, :keyword
  
  def make_keyword
    self.body.match(/^\s*(\S*)/)
    w = Keyword.first({:word => $1.upcase})
    if w.nil?
      self.keyword = Keyword.new({:word => $1.upcase})
    else
      self.keyword = w
    end
  end
  
  def create_subscriber
    sub = Subscriber.first({:number => self.number})
    self.subscriber = sub.nil? ? Subscriber.new({:number => self.number}) : sub
    self.subscriber.active = true
  end
  
  def process_system_keywords
    case self.keyword.word
    when /stop/i
      self.subscriber.active = false
    end
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
