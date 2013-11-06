class TelephonyAccount
  include DataMapper::Resource
  property :id, Serial
  property :number, String, :required => true
  property :provider, String, :required => true
  timestamps :at
  has n, :quizzes
  has n, :text_messages
  has n, :subscribers

  def activate_quiz(q)
    self.quizzes.update(:active => false)
    quiz = self.get_quiz(q.id)
    quiz.active = true
    return self.save    
  end

  def deactivate_quiz(q)
    quiz = self.get_quiz(q.id)
    quiz.active = false
    return quiz.save
  end

  def get_quiz(id)
    q = self.quizzes.get(id)
    raise 'quiz does not exist' if q.nil?
    q
  end

end
