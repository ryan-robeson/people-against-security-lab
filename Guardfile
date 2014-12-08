# A sample Guardfile
# More info at https://github.com/guard/guard#readme

## Uncomment and set this to only include directories you want to watch
# directories %(app lib config test spec feature)

## Uncomment to clear the screen before every task
# clearing :on

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
    watch('people_against_security.rb') 
  end

  guard 'livereload' do
    watch(%r{views/.+\.(erb|haml|slim)$})
    #watch(%r{helpers/.+\.rb})
    watch(%r{public/.+\.(css|js|html)})
    #watch(%r{config/locales/.+\.yml})
    # Rails Assets Pipeline
    #watch(%r{(app|vendor)(/assets/\w+/(.+\.(css|js|html|png|jpg))).*}) { |m| "/assets/#{m[3]}" }
  end
end

guard :minitest do
  # with Minitest::Unit
  watch(%r{^test/(.*)\/?(.*)_test\.rb$})
  #watch(%r{^lib/(.*/)?([^/]+)\.rb$})     { |m| "test/#{m[1]}test_#{m[2]}.rb" }
  watch(%r{^test/test_helper\.rb$})      { 'test' }
  watch("people_against_security.rb") { 'test' }

  # with Minitest::Spec
  # watch(%r{^spec/(.*)_spec\.rb$})
  # watch(%r{^lib/(.+)\.rb$})         { |m| "spec/#{m[1]}_spec.rb" }
  # watch(%r{^spec/spec_helper\.rb$}) { 'spec' }
end
