class TextMessage
  include DataMapper::Resource
  property :id, Serial
  property :body, String, :required => true, :length => 160
  # property :keyword, String, :length => 160
  property :from_number, String, :required => true
  property :to_number, String, :required => true
  timestamps :at

  # before :save, :make_keyword
  before :save, :create_subscriber
  before :save, :activate_subscribers
  before :save, :process_system_keywords

  # has 1, :subscriber
  # has 1, :campaign

  def activate_subscribers
    subs = Subscriber.all(:to_number => self.to_number, :from_number => self.from_number).each do |sub|
      sub.update(:active => true)
    end
  end

  def create_subscriber
    # camp_exists = Campaign.first(:keyword => self.possible_keyword, :to_number => self.to_number)
    # c = camp_exists.nil? ? Campaign.create(:name => CATCH_ALL_KEYWORD, :keyword => CATCH_ALL_KEYWORD, :to_number => self.to_number) : camp_exists
    Subscriber.first_or_create(:from_number => self.from_number, :to_number => self.to_number)
  end

  def possible_keyword
    key.upcase
  end

  def key
    self.body.match(/^\s*(\S*)/)
    $1
  end

  def value
    self.body.match(/^\s*\S+\s*(\S+)$/)
    $1
  end

  def process_system_keywords
    case self.key.upcase
    when 'STOP'
      Subscriber.unsubscribe(self)
    when 'ACTIVATE'
      u = User.first(:uid => self.value)
      u.phone = self.from_number
      u.activate
    end
  end

  def self.create_text_message(message)
    tm = self.new(message)
    return tm.save
  end

end