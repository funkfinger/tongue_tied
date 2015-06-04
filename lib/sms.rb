class Sms
  attr_accessor :provider
  def send_message(from_number, to_number, message)
    raise 'not implemented - create it through the create method' if @provider.nil?
    log_message(from_number, to_number, message)
  end

  def send_messages(message, from_number, to_numbers)
    to_numbers.each do |number|
      self.send_message(from_number, number, message)
    end
  end

  def log_message(from_number, to_number, message)
    ta = TelephonyAccount.first(:number => from_number)
    raise "bad telephony account" if ta.nil?
    ta.sms_logs.new(:body => message, :to_number => to_number)
    raise "log saving issue" unless ta.save
  end

  def self.create(provider_type)
    case provider_type
    when 'twilio'
      @sms_provider = TwilioSms.new
    when 'plivo'
      @sms_provider = PlivoSms.new
    end
  @sms_provider.provider = provider_type
  @sms_provider
  end
end

class TwilioSms < Sms
  def send_message(from_number, to_number, message)
    raise 'not implemented yet'
    super
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
    super
  end
end