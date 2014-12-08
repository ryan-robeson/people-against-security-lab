require 'rubygems'
require 'bundler'

Bundler.require

require_relative "people_against_security"

run Sinatra::Application
