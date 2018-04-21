#!/usr/bin/env bash
set -e
# set -x # Uncomment to debug

MY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd ${MY_DIR}

if [[ -z `which ruby` ]]; then
  echo "Missing ruby in your path. Please install the correct version and try again" && exit 1
fi

if [[ -z `which gem` ]]; then
  echo "Missing rubygems in your path. Please install the correct version and try again" && exit 1
fi

if [[ -z `which bundle` ]]; then
  echo "Installing bundler..."
  gem --version &> /dev/null && gem install -v 1.16.0 &> /dev/null
fi

OSX="false"
if [[ -n `uname -a | grep Darwin` ]]; then
  OSX="true"
fi

if [[ ${OSX} == "true" ]] && [[ -z `which brew` ]]; then
  echo "Installing brew. This will ask for your password..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

if [[ ${OSX} == "false" ]] && [[ -z `which apt-get` ]]; then
  echo "This setup is only ready for apt-get based linuxes and OSX. You'll have to open and edit this file to fix it for your distribution."
  exit 1
fi

if [[ -z `which identify` ]]; then
  echo "Installing imagemagick..."
  if [[ ${OSX} == "true" ]]; then
    (brew --version &> /dev/null && brew install imagemagick &> /dev/null)
  fi
  if [[ ${OSX} == "false" ]]; then
    (apt-get --version &> /dev/null && apt-get install -y imagemagick &> /dev/null)
  fi
fi

if [[ -z $(command -v mysql) ]]; then
  echo "Installing mysql..."
   if [[ ${OSX} == "true" ]]; then
    (brew --version &> /dev/null && brew install mysql &> /dev/null)
  fi
  if [[ ${OSX} == "false" ]]; then
    (apt-get --version &> /dev/null && apt-get install -y mysql-client mysql-server libmysqlclient-dev &> /dev/null)
  fi

fi

echo "Installing gem dependencies..."
bundle install
