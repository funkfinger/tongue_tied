require_relative 'plivo'
require_relative 'twilio'
require_relative 'betwext'
require_relative 'omniauth'
require_relative 'user'
require_relative 'telephony_account'
require_relative 'quiz'
require_relative 'sms'


class TongueTiedApp < Sinatra::Base
	set :views, Proc.new { File.join(root, "../../views") }
end
