#!/usr/bin/env bash
#
# big thanks to Paul who wrote the original script:
#
#   https://gist.github.com/apelade/8203553
#
#
# run this script using:
#   source ./scripts/rails_setup.sh
#
#
# tested on these platforms:
#
#   Ubuntu 14.04
#   OS X Mavericks
#
#
# references:
#
#   https://gorails.com/setup/ubuntu/14.04
#


echo "
####################### AgileVentures #############################

  This script sets up the environment for a basic Rails
  application. Grab a drink, this could take a while.


  Want to find out more about what this does, checkout the repo:

    https://github.com/AgileVentures/setup-scripts


  Hit ENTER to continue
"
read -s


echo "
####################### DEPENDENCIES ##############################
"
if [ $(uname) = "Linux" ]; then
  sudo apt-get update
  sudo apt-get install curl postgresql-common postgresql-9.3 libpq-dev \
    libgdbm-dev libncurses5-dev automake libtool bison libffi-dev \
    libqtwebkit-dev \
    nodejs # npm nodejs-dev conflicts with nodejs as it contains them (14.04)
  if [ -n "$HEADLESS" ]; then
      sudo apt-get install -y xvfb
  fi

elif [ $(uname) = "Darwin" ]; then
  if ! hash brew 2>/dev/null; then
    ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
  fi

  brew update
  brew doctor
  brew install qt
  brew install postgresql
  brew install node
fi

if [ -n "$WITH_PHANTOMJS" ]; then
  sudo npm install -g phantomjs # need sudo
fi

echo "
########################### Ruby ##################################
"
# Setup rvm environment
function rvm-only {
if [ -n "$REQUIRED_RUBY" ]; then
  if ! rvm list | grep $REQUIRED_RUBY; then
    echo "Installing ruby-$REQUIRED_RUBY"
    rvm install $REQUIRED_RUBY
    rvm use $REQUIRED_RUBY
  else
    rvm use $REQUIRED_RUBY
  fi
  ruby -v
  echo

  if [ -n $GEMSET ]; then
    if ! rvm gemset list | grep $GEMSET; then
      echo "Creating a new gemset $REQUIRED_RUBY@$GEMSET"
      rvm gemset create $GEMSET
      echo "ruby-$REQUIRED_RUBY" > .ruby-version
      echo "$GEMSET" > .ruby-gemset
      rvm use $REQUIRED_RUBY@$GEMSET
    else
      echo "Detected gemset ruby-$REQUIRED_RUBY@$GEMSET"
      rvm use $REQUIRED_RUBY@$GEMSET
    fi
    echo
  fi
fi
}

# Check if rbenv or rvm is installed
# Does not imply installing rbenv,
# Only if rbenv is present install plugins
if hash rbenv 2>/dev/null; then
  # Ruby fails to build, falling back to new version
  if [ $REQUIRED_RUBY=="2.1.1" ]; then
    REQUIRED_RUBY="2.1.2"
  fi
  if ls -la ~/.rbenv/plugins/ruby-build &> /dev/null && \
    ls -la ~/.rbenv/plugins/rbenv-gemset &> /dev/null; then
    if ! rbenv versions | grep $REQUIRED_RUBY; then
      rbenv install -v $REQUIRED_RUBY
    fi
    echo "$REQUIRED_RUBY" > .ruby-version
    echo "$GEMSET" > .rbenv-gemsets
  else
    # Use custom installation script
    wget https://raw.githubusercontent.com/neosb/rbenv-install/master/rbenv-install
    if ! ls -la ~/.rbenv/plugins/rbenv-gemset &> /dev/null; then
      source rbenv-install --only-rbenv-gemset
      echo "$GEMSET" > .rbenv-gemsets
    fi
    if ! ls -la ~/.rbenv/plugins/ruby-build &> /dev/null; then
      source rbenv-install --only-ruby-build
      rbenv install -v $REQUIRED_RUBY
      echo "$REQUIRED_RUBY" > .ruby-version
    fi
    # Cleanup
    rm rbenv-install
  fi
elif hash rvm 2>/dev/null; then
  rvm get stable
  rvm-only
else
  \curl -sSL https://get.rvm.io | bash -s stable --ruby --auto-dotfiles
  source ~/.rvm/scripts/rvm
  rvm-only
fi
echo

# Set Gemfile to reflect installed Ruby version (needed to fallaback to 2.1.2)
sed -i "1 c\
ruby '$REQUIRED_RUBY'" Gemfile

# Install Bundler as a gem otherwise will install older Ruby version before 2.0
gem install bundler

if [ -z $SKIP_BUNDLE ]; then
  bundle install
fi

if [ -z $SKIP_MIGRATIONS ]; then
  echo "Running migrations"
  bundle exec rake db:create:all
  bundle exec rake db:setup
  bundle exec rake db:test:prepare
fi
