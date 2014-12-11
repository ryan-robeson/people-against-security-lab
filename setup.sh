#!/usr/bin/env bash
# Designed to automate the following steps for Kali Linux.
# Then install the "People Against Security" lab.
#    * `aptitude update && aptitude safe-upgrade`
#* Install development libraries (required to build ruby 2)
#    * `aptitude install libssl-dev ruby1.9.1-dev libsqlite3-dev`
#* Install Ruby 2
#    * `git clone https://github.com/sstephenson/rbenv.git ~/.rbenv`
#    * `echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile`
#    * `echo 'eval "$(rbenv init -)"' >> ~/.bash_profile`
#    * Close and reopen terminal
#    * `git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build`
#    * `rbenv install 2.1.0`
#* Configure Ruby 2 as the default
#    * For the current shell only if you're worried about it
#        * `rbenv shell 2.1.0`
#    * Or globally (within Kali) for convenience and the latest features
#        * `rbenv global 2.1.0`

set -e # Die on error


echo !!!Designed for and tested on Kali Linux 1.0.9!!!
echo It assumes a fresh install. Take care if running on an
echo existing system.
echo This may work on Ubuntu as well, but no promises.
echo Press any key to continue or ctrl-c to quit.
read -p "..." -n 1 -r
echo

echo Here we go....
echo This may take some time. Go grab a coffee or something

echo Updating packages...

sudo aptitude update

echo Installing development libraries...

sudo aptitude install -y libssl-dev ruby1.9.1-dev libsqlite3-dev

echo Installing Ruby 2...

git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

rbenv install 2.1.0

rbenv global 2.1.0

echo Installing PAS...

gem install --no-ri --no-rdoc *.gem

echo
echo
echo
echo Setup complete.
echo Close and open a new terminal for everything to work right.
echo Then, start the lab with the command people_against_security
echo
echo
