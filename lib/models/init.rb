require 'data_mapper'

db_connection_string = "postgres://#{ENV['DB_USER']}:#{ENV['DB_PASS']}@#{ENV['DB_HOST']}/#{ENV['DB_NAME']}"
DataMapper.setup(:default, db_connection_string)

require_relative 'text_message'
require_relative 'campaign'
require_relative 'plivo'
require_relative 'betwext'
require_relative 'keyword'
require_relative 'subscriber'
require_relative 'twilio'
require_relative 'subscriber_message'
require_relative 'user'
require_relative 'quiz'
require_relative 'telephony_account'


# DataMapper.auto_migrate!
# DataMapper.finalize
DataMapper.auto_upgrade!

CATCH_ALL_KEYWORD = "CATCHALLKEYWORD"


class Hash
  def slice(*keys)
    keys.map! { |key| convert_key(key) } if respond_to?(:convert_key, true)
    keys.each_with_object(self.class.new) { |k, hash| hash[k] = self[k] if has_key?(k) }
  end
  
  def slice!(*keys)
    keys.map! { |key| convert_key(key) } if respond_to?(:convert_key, true)
    omit = slice(*self.keys - keys)
    hash = slice(*keys)
    replace(hash)
    omit
  end
end
