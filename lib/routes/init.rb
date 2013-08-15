require_relative 'plivo'
require_relative 'twilio'
require_relative 'betwext'
require_relative 'omniauth'

class TongueTiedApp < Sinatra::Base
	set :views, Proc.new { File.join(root, "../../views") }
end