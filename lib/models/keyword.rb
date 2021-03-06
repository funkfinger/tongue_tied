class Keyword
  include DataMapper::Resource
  property :id, Serial
  property :word, String, :required => true, :length => 160
  property :response, String, :required => true, :length => 160

  before :save, :upcase_word

  belongs_to :telephony_account
  has n, :subscribers, :through => Resource

  def upcase_word
    self.word.upcase!
  end

end
