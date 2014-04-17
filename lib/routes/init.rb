require_relative 'plivo'
require_relative 'twilio'
require_relative 'betwext'
require_relative 'omniauth'
require_relative 'user'
require_relative 'telephony_account'
require_relative 'quiz'
require_relative 'sms'
require_relative 'subscriber_list'


class TongueTiedApp < Sinatra::Base
	set :views, Proc.new { File.join(root, "../../views") }

  def get_telephony_account(id)
    ta = TelephonyAccount.first(:id => id)
    halt 500, 'API error - bad telephony account id' if ta.nil?
    ta
  end

end
