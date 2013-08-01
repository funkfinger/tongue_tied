class Campaign
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :required => true, :length => 160
  property :keyword, String, :required => true, :length => 160
  property :to_number, String, :required => true

  has n, :subscribers
    
  before :save, :upcase_keyword

  
  def upcase_keyword
    self.keyword.upcase!
  end
  
end