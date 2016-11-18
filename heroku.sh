#!/bin/bash

read -p "Would like to do a force push? [Y/N] " push

export APP_NAME="com-prototype"
export HEROKU_REMOTE="heroku-$APP_NAME"

echo
echo "# Creating a new Heroku App"
echo
heroku apps:create --region eu --remote $HEROKU_REMOTE $APP_NAME

echo
echo "# Creating a Heroku PostgreSQL instance"
echo
heroku addons:create heroku-postgresql:hobby-dev --app $APP_NAME
heroku pg:wait --app $APP_NAME

export DB_USER=`heroku config -s | grep DATABASE_URL | awk -F:// '{print $2}' | awk -F: '{print $1}'`
export DB_PASS=`heroku config -s | grep DATABASE_URL | awk -F: '{print $3}' | awk -F@ '{print $1}'`
export DB_HOST=`heroku config -s | grep DATABASE_URL | awk -F: '{print $3}' | awk -F@ '{print $2}'`
export DB_NAME=`heroku config -s | grep DATABASE_URL | awk -F/ '{print $4}' | sed "s/\'//g"`
export DB_PORT=`heroku config -s | grep DATABASE_URL | awk -F: '{print $4}' | awk -F/ '{print $1}'`

echo
echo "# Configuring Heroku ready for COM-PROTOTYPE"
echo
heroku config:set \
--app $APP_NAME \
COM_PROTOTYPE_DATABASE_USER=$DB_USER \
COM_PROTOTYPE_DATABASE_PASSWORD=$DB_PASS \
COM_PROTOTYPE_DATABASE_HOST=$DB_HOST \
COM_PROTOTYPE_DATABASE_NAME=$DB_NAME \
COM_PROTOTYPE_DATABASE_PORT=$DB_PORT

echo
echo "# Pushing the current branch to Heroku's master"
echo
export CURRENT_BRANCH_NAME=`git branch | grep "^\*" | cut -d" " -f2`

if [[ $push == "Y" ]]; then
  git push -f $HEROKU_REMOTE $CURRENT_BRANCH_NAME:master
else
  git push $HEROKU_REMOTE $CURRENT_BRANCH_NAME:master
fi

echo
echo "# Setup Heroku PostgreSQL DB $DB_NAME"
echo
heroku run rake db:migrate
heroku run rake import:all

echo
echo "# Opening App"
echo "*NOTE.* You may have to refresh as the app can be slow to start"
echo
open `heroku apps:info --app $APP_NAME | grep "Web URL" | cut -c16-`

echo
echo "*Set ERRBIT_API_KEY and ERRBIT_HOST manually to enable error reporting*"
echo "*You can find those key values on https://errbit.<environment>.publishing.service.gov.uk*"
echo "All done"
echo
