gem 'capybara','2.5.0'
gem 'poltergeist', '1.7.0'

require 'capybara'
require 'capybara/poltergeist'
require 'nokogiri'
require 'date'
require 'json'

Dir['./lib/**/*.rb'].each do |dep|
    require dep
end