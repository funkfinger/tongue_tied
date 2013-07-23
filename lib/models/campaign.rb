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
