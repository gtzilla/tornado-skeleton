#!/bin/bash
#
# author: gregory tomlinson
# copyright: 2013
# Liscense: MIT
# repos: https://github.com/gregory80/heroku-skeleton
# 
# Usage:
#     bash build_env.sh ~/path/to/app
#     cd ~/path/to/app
#     bash app/scripts/runlocal.sh #start server on port 5000
# 
# Inspired by mike dory on Tornado-Heroku-Quickstart
# https://github.com/mikedory/Tornado-Heroku-Quickstart
#
# see README.md
# 
# gunicorn for heroku start code via 
# https://github.com/mccutchen
# 
if [ $# -lt 1 ]; then
  echo "Usage: build_env.sh <../path/to/myapp>"
  exit 1
fi
#
# options
INSTALL_PIP=true
INSTALL_VENV=true
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_GIT="https://raw.github.com/gregory80/heroku-skeleton/master"
JS_LIB_FILES=(
  'http://code.jquery.com/jquery-1.10.2.js' 
  'http://backbonejs.org/backbone.js'
  'http://underscorejs.org/underscore.js' 
  'https://raw.github.com/jeffreytierney/newT/master/newT.js'
  'https://raw.github.com/janl/mustache.js/master/mustache.js'
  )
JS_FILES=(
  'http://requirejs.org/docs/release/2.1.9/comments/require.js'
  'https://raw.github.com/requirejs/text/master/text.js'
  'http://requirejs.org/docs/release/2.1.9/r.js'
  # 'https://raw.github.com/janl/mustache.js/master/mustache.js'
  )
APP_FILES=(
  "Procfile" 
  ".env" 
  "app/config/dev.conf"
  "requirements.txt"
  "app/webapp.py" 
  "app/templates/main.html"
  "app/static/css/app.css" 
  "app/static/js/App.js" 
  "app/static/js/main.js" 
  "app/static/templates/homepage.html" 
  "app/static/js/WorkspaceRouter.js" 
  "app/static/js/views/HomepageView.js" 
  "app/scripts/runlocal.sh"
  
  )
#
# source in config file
if [ -f "$HOME/.build_env.config" ]; then
    echo "Found and sourcing ~/.build_env.config"
    . "$HOME/.build_env.config"
fi
#
#
echo "Starting heroku-skeleton stub out, version 0.0.1"
echo "Report issues to github issues:"
echo "https://github.com/gregory80/heroku-skeleton"
echo "Creating application $1"
echo "...................."
sleep 1
#
# first create the directory
#
mkdir -p $1
pushd $1 > /dev/null
#
#
mkdir -p app/scripts app/static app/config app/hooks
touch README.md requirements.txt .gitignore .env
# make virtual env
#
#
if $INSTALL_VENV; then
  virtualenv venv --distribute
  source venv/bin/activate
fi
#
pushd app > /dev/null
# in the app folder
touch webapp.py __init__.py config/dev.conf scripts/runlocal.sh
#
#
# Add External JS Files
mkdir -p static/js/libs static/templates static/js/views static/js/models static/js/collections 
# now the CSS and others
mkdir -p static/css static/graphics templates
# begin download of JS LIB files
pushd static/js/libs > /dev/null
echo "Fetching static JS library files"
#
for jsfile in ${JS_LIB_FILES[@]}
do
  filepath=(${jsfile//\// })
  curl ${jsfile} -o ${filepath[${#filepath[@]}-1]} 2&> /dev/null
done
#
#
popd > /dev/null

pushd static/js > /dev/null
echo "Fetching static JS library files"
#
for jsfile in ${JS_FILES[@]}
do
  filepath=(${jsfile//\// })
  curl ${jsfile} -o ${filepath[${#filepath[@]}-1]} 2&> /dev/null
done
#
#
popd > /dev/null


#
function readTmplFile {
  if [ -f "$2" ]; then
    # echo "copying local file $1"
    # use the local copy
    cat "$2" > "$1"
  else
    # fail over to remote
    echo "Requesting $3"
    curl -fsSL "$3" -o "$1" 2>/dev/null
  fi
  return 0
}
#
#
#
# leave the app/ dir
popd > /dev/null
#
echo "Download the app_files"
for kfile in ${APP_FILES[@]}
do
  # echo "attempt to copy ${kfile}"
  # echo "${SCRIPTDIR}/build_templates/${kfile}" "${BASE_GIT}/build_templates/${kfile}"
  readTmplFile "${kfile}" "${SCRIPTDIR}/build_templates/${kfile}" "${BASE_GIT}/build_templates/${kfile}"
  # echo "${file_str}" > ${kfile}
done
#
# pip install basic packages
# only tornado is TRULY needed
# the rest make like easier
if $INSTALL_PIP; then
  echo "Installing pip from requirements.txt"
  cat "requirements.txt"
  pip install -r requirements.txt
  # echo ls -la
fi
#
# build the requirements file
#
# pip freeze > requirements.txt
echo "This is a stub for tornado on heroku" > README.md
#
#
echo "*.pyc" >> .gitignore
echo ".DS_Store" >> .gitignore
echo ".env" >> .gitignore
echo "venv/" >> .gitignore
#
# iniitalize git, add our files
git init .
#
# commit it
git add .
git commit -m "initial commit"
#
# add hooks, hooks require web app started!
# chmod +x app/hooks/pre-commit-msg.sh
# requires abs path b/c is an alias
# ln -s $1/app/hooks/pre-commit-msg.sh .git/hooks/pre-commit
#
#
echo "...................................................."
echo "Your application is ready! $1"
echo "Start your webapp by executing"
echo "bash $1/app/scripts/runlocal.sh"
echo "to start server on port 5000"
echo ""
echo "Configure local dev environment with .env"
echo "Did you know? You can configure this script with ~/.build_env.config"
echo "...................................................."
#
#
terminal-notifier -message "Skeleton complete" -title "Installed!"
exit 0

