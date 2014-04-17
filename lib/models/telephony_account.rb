class TelephonyAccount
  include DataMapper::Resource
  property :id, Serial
  property :number, String, :required => true
  property :provider, String, :required => true
  property :response, String, :length => 160

  timestamps :at
  has n, :quizzes
  has n, :text_messages
  has n, :subscribers
  has n, :keywords
  has n, :sms_logs
  has n, :subscriber_lists

  def activate_quiz(q)
    self.quizzes.each do |quiz|
      quiz.active = false
    end
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

  def get_active_quiz
    qzs = self.quizzes.all(:active => true)
    raise 'more than one quiz active' if qzs.count > 1
    raise 'no active quiz found' if qzs.empty?
    qzs.first
  end

end
