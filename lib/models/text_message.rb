class TextMessage
  include DataMapper::Resource
  property :id, Serial
  property :body, String, :required => true, :length => 160
  property :from_number, String, :required => true
  property :to_number, String, :required => true
  timestamps :at

  belongs_to :telephony_account

  validates_format_of :body, with: /\S+/i, allow_blank: false, message: "body cannot me blank"

  before :save, :create_and_activate_subscriber
  before :save, :process_system_keywords
  before :save, :send_telephony_account_responses
  before :save, :process_quiz_response


  def send_telephony_account_responses
    keyword = self.telephony_account.keywords.first(:word => self.possible_keyword)
    sms = Sms.create(self.telephony_account.provider)
    if !keyword.nil?
      sms.send_message(self.telephony_account.number, self.from_number, keyword.response)
    else
      generic_response_message = self.telephony_account.response
      sms.send_message(self.telephony_account.number, self.from_number, generic_response_message) unless generic_response_message.blank?
    end

  end

  def process_quiz_response
    active_quiz_question = self.telephony_account.quizzes(:active => true).quiz_questions(:active => true).first
    return if active_quiz_question.nil?
    return if active_quiz_question.quiz.subscribers.get(@s.id).nil?
    return active_quiz_question.quiz_question_responses.new(:body => self.body, :subscriber => @s).save
  end

  def activate_subscribers
    subs = self.telephony_account.subscribers.all(:to_number => self.to_number, :from_number => self.from_number).each do |sub|
      sub.update(:active => true)
    end
  end

  def create_and_activate_subscriber
    @s = self.telephony_account.subscribers.first_or_create(:from_number => self.from_number, :to_number => self.to_number)
    @s.update(:active => true)
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
    when 'QUIZ'
      q = self.telephony_account.quizzes.first(:active => true)
      if not q.nil?
        q.subscribers << @s
        q.save
      end  
    end
  end

  def self.create_text_message(message)
    ta = TelephonyAccount.first(:number => message[:to_number].gsub(/[^\d]/, '')) # strip all but digits...
    return false if ta.nil?
    tm = ta.text_messages.new(message)
    return ta.save
  end

end