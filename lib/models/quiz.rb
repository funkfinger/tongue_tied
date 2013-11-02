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
  has n, :subscribers
end

class QuizQuestion
  include DataMapper::Resource
  property :id, Serial
  property :body, String, :required => true
  timestamps :at
  belongs_to :quiz
end


