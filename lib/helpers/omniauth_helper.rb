module OmniAuthHelpers

  def signed_in?
    !session[:uid].nil?
  end

  def logout_link
    raise if session[:uid].nil?
    u = User.first(:uid => session[:uid])
    raise "session = #{session.to_yaml}" if u.nil?
    "<a href='#'>logged in as #{u.name} | logout</a>"
  end

end