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

  def self.create_text_message(message)
    tm = self.new(message)
    return tm.save
  end

end