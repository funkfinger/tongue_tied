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
  timestamps :at
  
  after :create , :create_keyword
  
  def create_keyword
    # TODO: this stinks, hopefully temporary
    ta = TelephonyAccount.first_or_new(:number => 4806668601, :provider => 'betwext')
    k = ta.keywords.first(:word => self.keyword)
    if k.nil? 
      k = ta.keywords.new(:word => self.keyword, :response => 'back atcha')
      raise unless k.save
    end
  end
  
end