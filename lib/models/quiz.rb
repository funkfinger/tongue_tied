# DataMapper::Inflector.inflections.irregular 'quiz', 'quizzes'

class Quiz
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :required => true
  timestamps :at
  has n, :quiz_questions
  belongs_to :telephony_account
end

class QuizQuestion
  include DataMapper::Resource
  property :id, Serial
  property :body, String, :required => true
  timestamps :at
  belongs_to :quiz
end
