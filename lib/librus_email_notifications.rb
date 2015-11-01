require 'capybara'
require 'capybara/poltergeist'
require 'nokogiri'
require 'date'
require 'json'

Dir['./lib/**/*.rb'].each do |dep|
    require dep
end