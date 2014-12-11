require 'bundler'

Bundler.setup

require_relative "lib/people_against_security"

run Sinatra::Application
