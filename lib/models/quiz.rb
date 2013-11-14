# DataMapper::Inflector.inflections.irregular 'quiz', 'quizzes'

class Quiz
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :required => true
  property :response_message, String, :required => true, :length => 160

  property :active, Boolean, :required => true, :default => false
  timestamps :at
  has n, :quiz_questions
  belongs_to :telephony_account
  has n, :subscribers, :through => Resource

  def set_active_question(question)
    questions = self.quiz_questions.all()
    questions.update(:active => false)
    questions.save
    question.active = true
    question.save
  end

  def active_question
    self.quiz_questions.first(:active => true)
  end

  def active_subscribers
    self.subscribers.all(:active => true)
  end

  def send_active_question
    sms = Sms.create(self.telephony_account.provider)
    self.active_subscribers.each do |subscriber|
      sms.send_message(self.telephony_account.number, subscriber.from_number, self.active_question)
    end
  end

end

class QuizQuestion
  include DataMapper::Resource
  property :id, Serial
  property :body, String, :required => true
  property :active, Boolean, :required => true, :default => false
  timestamps :at
  belongs_to :quiz
  has n, :quiz_question_responses
end

class QuizQuestionResponse
  include DataMapper::Resource
  property :id, Serial
  property :body, String, :required => true
  property :active, Boolean, :required => true, :default => true
  timestamps :at
  belongs_to :quiz_question
  belongs_to :subscriber

  before :create, :deactivate_prior_responses_and_activate_self

  def deactivate_prior_responses_and_activate_self
    self.quiz_question.quiz_question_responses.all(:subscriber => self.subscriber).update!(:active => false)
    self.active = true
  end

end


