require 'bundler/setup'
require 'guard/guard'
require 'guard/livereload'
require 'guard/shotgun'
require 'guard/minitest'

# Monkey-patch shotgun so it only get's called once for Vim saves.
# Same for minitest.
module ::Guard
  class Shotgun < Plugin
    define_method :run_on_modifications do |paths|
      @reloaded = true
      restart_without_waiting
    end

    define_method :run_on_changes do |paths|
    end

    undef_method :run_on_change
  end

  class Minitest < Plugin
    undef_method :run_on_additions
    undef_method :run_on_removals
  end
end

group :server do
  guard :shotgun do
    watch('lib/people_against_security.rb') 
  end

  guard 'livereload' do
    watch(%r{lib/views/.+\.(erb|haml|slim)$})
    watch(%r{public/.+\.(css|js|html)})
  end
end

guard :minitest, include: ['lib'] do
  # with Minitest::Unit
  watch(%r{^test/(.*)\/?(.*)_test\.rb$})
  watch(%r{^test/test_helper\.rb$})      { 'test' }
  watch("lib/people_against_security.rb") { 'test' }
end
