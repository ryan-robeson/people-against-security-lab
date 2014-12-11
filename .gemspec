require_relative 'lib/people_against_security/version'

Gem::Specification.new do |s|
  s.name = "people_against_security"
  s.version = PeopleAgainstSecurity::VERSION
  s.authors = ["Ryan Robeson"]
  s.email = ["ryan.robeson@gmail.com"]
  s.summary = "Small Sinatra app designed to demonstrate the importance of security in web applications to undergraduate students."
  s.description = %q|
      This was a final exam project for CSCI-5460 - Network and Information Security.
      The assignment was to design a lab suitable for Undergraduate security students to complete in 4-6 hours that demonstrated something important in the area of security.
      The goal of this lab is to give students a basic understanding of how seemingly minor vulnerabilities in web applications can come together to cause major problems.|
  s.required_ruby_version = '~> 2.1'
  s.require_paths = ["lib"]
  s.files = `git ls-files`.split("\n") - %w[doc/ setup.sh] + %w[wordlist.txt]
  s.test_files = `git ls-files -- test/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.default_executable = 'people_against_security'
  s.post_install_message = %q|
  You have successfully installed "People Against Security".
  To start the lab now, type: people_against_security
  and hit enter.
  |

  s.add_dependency "bundler"
  s.add_dependency "sqlite3"
  s.add_dependency "sinatra"
  s.add_dependency "unicorn"
  s.add_dependency "rake"
  s.add_dependency "faker"
  s.add_dependency "rack-flash3"
  s.add_dependency "sinatra-redirect-with-flash"

  s.add_development_dependency "guard"
  s.add_development_dependency "rack-livereload"
  s.add_development_dependency "minitest"
  s.add_development_dependency "minitest-reporters"
  s.add_development_dependency "rack-test"
  s.add_development_dependency "capybara"
  s.add_development_dependency "guard-livereload"
  s.add_development_dependency "guard-shotgun"
  s.add_development_dependency "guard-minitest"
  s.add_development_dependency "pry"

  s.license = "MIT"
end
