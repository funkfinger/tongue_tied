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
    self.quizzes.get(q.id).active = true
    return self.save    
  end

  def deactivate_quiz(q)
    self.quizzes.get(q.id).active = false
    return self.save
  end

end
