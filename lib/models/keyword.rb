class Keyword
  include DataMapper::Resource
  property :id, Serial
  property :word, String, :required => true, :length => 160

  before :save, :upcase_word

  # has 1, :campaign
  belongs_to :campaign

  def upcase_word
    self.word.upcase!
  end

end
