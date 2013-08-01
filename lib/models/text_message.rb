class TextMessage
  include DataMapper::Resource
  property :id, Serial
  property :body, String, :required => true, :length => 160
  # property :keyword, String, :length => 160
  property :from_number, String, :required => true
  property :to_number, String, :required => true
  timestamps :at

  # before :save, :make_keyword
  # before :save, :create_subscriber
  before :save, :add_to_campaign
  before :save, :activate_subscribers
  before :save, :process_system_keywords

  # has 1, :subscriber
  # has 1, :campaign

  def activate_subscribers
    subs = Campaign.all(:to_number => self.to_number).each do |camp|
      camp.subscribers.all(:from_number => self.from_number).update(:active => true)
      # puts "\n\n camp.subscribers.all(:from_number => self.from_number) = #{camp.subscribers.all(:from_number => self.from_number).inspect} \n\n"
      camp.save
    end
  end

  def add_to_campaign
    camp_exists = Campaign.first(:keyword => self.possible_keyword, :to_number => self.to_number)
    c = camp_exists.nil? ? Campaign.create(:name => CATCH_ALL_KEYWORD, :keyword => CATCH_ALL_KEYWORD, :to_number => self.to_number) : camp_exists
    c.subscribers.first_or_create(:from_number => self.from_number)
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
    sub = Subscriber.first({:subscriber_number => self.number})
    self.subscriber = sub.nil? ? Subscriber.new({:subscriber_number => self.number}) : sub
    self.subscriber.active = true
  end

  def process_system_keywords
    case self.possible_keyword
    when /^stop$/i
      Subscriber.unsubscribe(self)
    end
  end

  def self.create_text_message(message)
    tm = self.new(message)
    return tm.save
  end

end