require_relative 'omniauth_helper'

class TongueTiedApp < Sinatra::Base
  helpers OmniAuthHelpers
end