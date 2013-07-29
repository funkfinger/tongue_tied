class TextMessage
  include DataMapper::Resource
  property :id, Serial
  property :body, String, :required => true, :length => 160
  # property :keyword, String, :length => 160
  property :from, String, :required => true
  property :to, String, :required => true
  timestamps :at

  # before :save, :make_keyword
  # before :save, :create_subscriber
  # before :save, :process_system_keywords
  after :save, :add_to_campaign

  # has 1, :subscriber
  # has 1, :campaign

  def add_to_campaign
    c = Campaign.first(:keyword => self.possible_keyword)
    c.subscribers.first_or_create(:number => self.from) unless c.nil?
  end

  def possible_keyword
    self.body.match(/^\s*(\S*)/)
    $1.upcase
    # w = Keyword.first({:word => $1.upcase})
    # if w.nil?
    #   self.keyword = Keyword.new({:word => $1.upcase})
    # else
    #   self.keyword = w
    # end
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