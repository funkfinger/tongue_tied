class Quiz
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :required => true
  timestamps :at
  has n, :quiz_questions
end

class QuizQuestion
  include DataMapper::Resource
  property :id, Serial
  property :body, String, :required => true
  timestamps :at
end
