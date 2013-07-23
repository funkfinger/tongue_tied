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
