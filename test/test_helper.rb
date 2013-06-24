ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'

ENV['TWILIO_ACCOUNT_SID']='AC50c36451e9ccffe77249b8ca05936b1a'
ENV['TWILIO_AUTH_TOKEN']='cc69499e93d89489afa13bc3fd9a31da'
ENV['DB_FLAVOR']='postgresql'
ENV['DB_HOST']='localhost'
ENV['DB_PORT']='5432'
ENV['DB_NAME']='tongue_tied_test'
ENV['DB_USER']='tongue_tied_user'
ENV['DB_PASS']='tongue_tied_pass'

require File.expand_path '../../tongue_tied.rb', __FILE__
