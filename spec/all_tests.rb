require './lib/librus_email_notifications'
require 'minitest'
require 'minitest/autorun'

Dir['./spec/**/*.rb'].each do |dep|
	require dep
end