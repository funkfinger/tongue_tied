# TODO: this stinks, hopefully temporary
def betwext_ta
  TelephonyAccount.first_or_new(:number => 4806668601, :provider => 'betwext')
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
  
  after :create, :create_betwext_keyword_and_subscriber
    
  def create_betwext_keyword_and_subscriber
    keyword = BetwextKeyword.first_or_create(:keyword => self.keyword.upcase)
    raise unless keyword.save
    # TODO: this stinks, hopefully temporary
    s = betwext_ta.subscribers.first_or_create(:from_number => self.sender_number)
    raise unless s.save
  end
  
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
  timestamps :at
  
  after :create , :create_keyword
  
  def create_keyword    
    k = betwext_ta.keywords.first(:word => self.keyword)
    if k.nil? 
      k = betwext_ta.keywords.new(:word => self.keyword, :response => 'back atcha')
      raise unless k.save
    end
  end
  
end