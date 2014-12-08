require 'singleton'
require 'forwardable'
require 'tempfile'

configure do
  enable :sessions
  set :session_secret, 'Ssshhh this is a secret'
  set :app_file, __FILE__
  use Rack::Flash
end

configure :development do
  Bundler.require(:default, :development)
  use Rack::LiveReload
end

class Db 
  include Singleton
  extend Forwardable

  attr_accessor :db

  def_delegator :@db, :execute, :execute

  # Use this file_name class variable to 
  # set the database path before initializing
  # the database.
  @@file_name = nil

  def Db.file_name= (path)
    @@file_name = path
  end

  def Db.file_name
    raise ArgumentError, "No filename provided before initializing" if @@file_name.nil?
    return @@file_name
  end

  def initialize
    # Store file_name in an instance variable
    # so it won't get changed in the future.
    @file_name = Db.file_name

    @db = SQLite3::Database.new @file_name
    # Turn on Foreign Key Constraints
    @db.execute("PRAGMA foreign_keys = ON;")

    create_tables

    seed
  end

  def create_tables
    @db.execute(%Q|
      create table if not exists users (
        id integer primary key,
        display_name varchar(30),
        email varchar(70) unique,
        password_hash char(32),
        is_admin boolean default 0,
        is_banned boolean default 0
      );
    |)
  end

  def seed
    # How many fake users to generate
    # The professor is placed in the middle of the users
    # table, so this number is doubled. e.g. 15 is actually 30
    number_of_users = 15

    passwords = potential_passwords

    # Insert Users
    @db.transaction do |d|
      # Only insert if the table is empty.
      # Inspired by: http://stackoverflow.com/a/5307178
      table_is_empty = d.get_first_value(%q|select "true" where not exists (select * from users)|)

      if table_is_empty
        d.prepare(%Q|
          insert into users (display_name, email, password_hash)
            values (?,?,?);
                  |) do |stmt|
          stmt.execute(["admin", "admin@gmail.com", md5("password")]) #Initial admin
          stmt.execute(["Bob", "bob@gmail.com", md5("password")]) #Initial user

          # Generate number_of_users users with random
          # passwords from the list of potential passwords.
          number_of_users.times do 
            stmt.execute(fake_user(passwords.sample))
          end

          # Create TheProfessor
          stmt.execute(["TheProfessor", "drSecurity@bigscaryinternet.com", md5(passwords.sample)])

          # Generate number_of_users users with random
          # passwords from the list of potential passwords.
          number_of_users.times do 
            stmt.execute(fake_user(passwords.sample))
          end
        end
      end
    end

    # Ban TheProfessor
    the_professor = get_user_by_name("TheProfessor")
    if the_professor.length == 1 and the_professor.first[4] == 0
      the_professor = the_professor.first.first
      set_user_banned_status(the_professor, 1)
    end

    # Setup the administrator
    admin = get_user_by_name("admin")
    if admin.length == 1 and admin.first[3] == 0
      admin = admin.first.first
      set_user_admin_status(admin, 1)
    end
  end

  def get_user(id)
    user = nil
    @db.transaction do |db|
      user = db.get_first_row("select id, display_name, email, is_admin, is_banned from users where id = ?", [id])
    end
    user
  end

  def get_user_by_name(name)
    @db.execute("select id, display_name, email, is_admin, is_banned from users where display_name = ?", [name])
  end

  def get_user_by_email(email)
    @db.execute("select id, display_name, email, is_admin, is_banned from users where email = ?", [email])
  end

  def get_all_users
    @db.execute("select id, display_name, email, is_admin, is_banned from users;")
  end

  def get_random_users
    get_all_users.sample(5) || []
  end

  def get_number_of_users
    @db.get_first_value("select count(id) from users;")
  end

  def get_total_banned_users
    @db.get_first_value("select count(id) from users where is_banned = 1;")
  end

  def insert_user(display_name, email, password)
    hash = md5(password)
    @db.transaction do |db|
      db.execute("insert into users (display_name, email, password_hash) values (?,?,?);", [display_name, email, hash])
    end
    @db.last_insert_row_id
  end

  def password_is_valid(email, password)
    hash = md5(password)
    @db.get_first_row("select id, display_name, email, is_admin, is_banned, password_hash from users where email = ? AND password_hash = ?;", [email, hash])
  end

  def set_user_admin_status(id, status)
    @db.transaction do |db|
      db.execute("update users set is_admin=? where id=?", [status ? 1 : 0, id])
    end
  end

  def set_user_banned_status(id, status)
    @db.transaction do |db|
      db.execute("update users set is_banned=? where id=?", [status ? 1 : 0, id])
    end
  end

  def md5(string)
    Digest::MD5.hexdigest string.chomp
  end

  def fake_user(password, hash: true)
    if hash
      password = md5(password)
    end
    [Faker::Internet.user_name, Faker::Internet.email, password]
  end

  def potential_passwords
    File.readlines("wordlist.txt")
  end
end

configure :production do
  Db.file_name = ".pas.db"
  set :db, Db.instance
end

configure :development do
  Db.file_name = "pas.db"
  set :db, Db.instance
end

configure :test do
  # Use an in-memory database for testing.
  Db.file_name = ":memory:"
  set :db, Db.instance
end

get '/' do
  @title = "Index"
  erb :index
end

get '/profile' do
  authorize!

  @title = "Home"
  @user = settings.db.get_user(session[:userid])
  @people_you_may_know = settings.db.get_random_users

  erb :profile
end

get '/register' do
  redirect '/profile' if authorized?

  @title = "Register"
  erb :register
end

post '/register' do
  message = nil

  [:display_name, :email, :password].each do |p|
    if params[p].empty?
      message = "All fields are required. Please try again."
      break
    end
  end

  if not message.nil?
    redirect '/register', error: message
  end

  id = settings.db.insert_user(params[:display_name], params[:email], params[:password])
  session[:userid] = id

  redirect '/profile', success: "Welcome to PAS!"
end

get '/login' do
  @title = "Login"
  erb :login
end

post '/login' do
  redirect '/login', error: "Error: email and password are required!" if params[:email].empty? || params[:password].empty?

  user = settings.db.password_is_valid(params[:email], params[:password])

  redirect '/login', error: "Error: Invalid email or password. Please try again" if user.nil?

  session[:userid] = user[0]

  redirect '/profile'
end

post '/logout' do
  logout!

  redirect '/'
end

get '/profile/reset_password' do
  authorize!
  @title = "Reset Password"
  
  erb :reset_password
end

get '/download/*' do
  file = params[:splat][0]
  f = ""

  case file
  when /\/?index.+/
    # Help student's out
    f = "people_against_security.rb"
  when /.+\.db$/
    # But not too much
    halt 403, "Can't download this"
  else
    f = file
  end

  send_file File.join(File.dirname(settings.app_file), f), disposition: :attachment
end

get '/admin/manage' do
  admin_only!

  @total_users = settings.db.get_number_of_users || 0
  @total_banned = settings.db.get_total_banned_users || 0

  erb :manage
end

get '/admin/manage/users' do
  authorize!

  @users = settings.db.get_all_users
  # Sort results
  @users = @users.sort { |u1,u2| u1[1] <=> u2[1] }if @users

  erb :manage_users
end

post '/admin/manage/users/toggle_admin' do
  authorize!

  if not params[:id]
    redirect '/admin/manage/users', error: "Cannot process request without id"
  end

  user = settings.db.get_user(params[:id])
  
  if not user
    redirect '/admin/manage/users', error: "The specified user does not exist"
  end

  message = ""
  if user[3] == 1
    settings.db.set_user_admin_status(user[0], false)
    message = "User demoted successfully."
  else
    settings.db.set_user_admin_status(user[0], true)
    message = "User promoted to admin successfully."
  end

  redirect '/admin/manage/users', success: message
end

post '/admin/manage/users/toggle_ban' do
  authorize!

  if not params[:id]
    redirect '/admin/manage/users', error: "Cannot process request without id"
  end

  user = settings.db.get_user(params[:id])
  
  if not user
    redirect '/admin/manage/users', error: "The specified user does not exist"
  end

  message = ""
  if user[4] == 1
    settings.db.set_user_banned_status(user[0], false)
    message = "User unbanned successfully."
  else
    settings.db.set_user_banned_status(user[0], true)
    message = "User banned successfully."
  end

  redirect '/admin/manage/users', success: message
end

get '/admin/manage/backup_database' do
  admin_only!
  # Wouldn't want any hackers getting a hold of this

  backup = Tempfile.new(['pas_backup', '.db'])
  begin
    system("sqlite3", settings.db.class.file_name, ".backup #{backup.path}")

    send_file backup.path, :filename => "pas.db"
  ensure
    backup.close
  end
end
  
helpers do
  # Include a page header
  # Usage:
  #   <%= page_header("Login") %>
  #   or
  #   <%= page_header("Login", "Welcome to PAS") %>
  def page_header(text, small=nil)
    erb %Q|
    <div class="row">
      <div class="col-xs-12">
        <div class="page-header">
          <h1>
            #{text}
            <% if not small.nil? %>
            <small>
            #{small}
            </small>
            <% end %>
          </h1>
        </div>
      </div>
    </div>
    |, locals: { small: small }
  end

  def authorized?
    if session[:userid] && settings.db.get_user(session[:userid])
      return true
    elsif session[:userid]
      logout!
      redirect '/'
    else
      return false
    end
  end

  def authorize!
    redirect '/login' unless authorized?
  end

  def admin_only!
    authorize!
    halt 403, "Unauthorized Access" unless is_admin?
  end

  def current_user
    if authorized?
      settings.db.get_user(session[:userid])
    end
  end

  def is_admin?
    if session[:userid]
      user = settings.db.get_user(session[:userid])
      if user
        return user[3] == 1
      end
    end
  end

  def is_user_banned?(id)
    user = settings.db.get_user(id)
    user && user[4] == 1
  end

  def is_user_admin?(id)
    user = settings.db.get_user(id)
    user && user[3] == 1
  end

  def logout!
    session[:userid] = nil
  end
end

