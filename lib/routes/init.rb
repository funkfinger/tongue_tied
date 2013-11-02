require_relative 'plivo'
require_relative 'twilio'
require_relative 'betwext'
require_relative 'omniauth'
require_relative 'user'
require_relative 'telephony_account'
require_relative 'quiz'

class TongueTiedApp < Sinatra::Base
	set :views, Proc.new { File.join(root, "../../views") }
end

class Sms
  def send_message(from_number, to_number, message)
    raise 'not implemented'
  end

  def send_messages(message, from_number, to_numbers)
    to_numbers.each do |number|
      self.send_message(from_number, number, message)
    end
  end

  def self.create(type)
    case type
    when 'twilio'
      @sms_provider = TwilioSms.new
    when 'plivo'
      @sms_provider = PlivoSms.new
    else
    end
  end
  @sms_provider
end

class TwilioSms < Sms
  def send_message(from_number, to_number, message)
    raise 'not implemented yet'
  end
end

class PlivoSms < Sms
  # include Plivo
  def send_message(from_number, to_number, message)
    params = {
      'src' => from_number,
      'dst' => to_number,
      'text' => message,
      'type' => 'sms'
    }
    p = Plivo::RestAPI.new(ENV['PLIVO_AUTHID'], ENV['PLIVO_TOKEN'])
    response = p.send_message(params)
    return response[0] < 400 ? true : false 
  end
end