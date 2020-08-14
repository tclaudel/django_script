#!/usr/bin/env bash

# CONFIG
PYTHON_VERSION="3.8.5"
DJANGO_VERSION="3.1"
LANGUAGE="fr-FR"





YELLOW="\033[0;33m"
RESET_COLOR="\033[0m"
RED="\033[0;31m"
BOLD="\033[1m"
UNDERLINE="\033[4m"


function check_python {
  CURRENT_PYTHON_VERSION=`python --version | cut -d ' ' -f 2`;
  if [[ $PYTHON_VERSION != $CURRENT_PYTHON_VERSION ]]; then
    printf "$YELLOW/!\ You are currently\033[1;33m python %s\033[0;33m, you need to upgrade your python version to %s\n" $CURRENT_PYTHON_VERSION $PYTHON_VERSION
    printf $RESET_COLOR
    read -r -p "Continue ? [y/N] : " response
    if [[ "$response" != "y" && "$response" != "Y" ]]; then
      printf "exiting ..."
      exit
    fi
  fi
}

function check_django {
  CURRENT_DJANGO_VERSION=`python3 -m django --version`
  if [[ $DJANGO_VERSION != $CURRENT_DJANGO_VERSION ]]; then
    printf "$YELLOW/!\ You are currently\033[1;33m python %s\033[0;33m, you need to upgrade your python version to %s\n" $CURRENT_DJANGO_VERSION $DJANGO_VERSION
    printf "$RESET_COLOR"
    read -r -p "Continue ? [y/N] : " response
    if [[ "$response" != "y" && "$response" != "Y" ]]; then
      printf "to install Django : pip install Django==%s\n" $DJANGO_VERSION
      printf "exiting ..."
      exit
    fi
  fi
}

function create_project {
  PROJECT_NAME=$1
  if [[ -z $PROJECT_NAME ]]; then
    read -r -p "project name ? : " PROJECT_NAME
  fi
  django-admin startproject "$PROJECT_NAME"
  mkdir -p "$PROJECT_NAME"/static/css
  mkdir -p "$PROJECT_NAME"/static/img
  mkdir -p "$PROJECT_NAME"/static/js
  mkdir -p "$PROJECT_NAME"/templates
  @ change_settings
}

function change_settings {
  sed -i "s/LANGUAGE_CODE = 'en-us'/LANGUAGE_CODE = '$LANGUAGE'/g" ./$PROJECT_NAME/$PROJECT_NAME/settings.py
}

function create_app {
  APP_NAME=$1
  if [[ -z $APP_NAME ]]; then
    read -r -p "app name ? : " APP_NAME
  fi
  python manage.py startapp $APP_NAME
  if [[ $? -ne 0 ]]; then
    printf "This error is usually due to an execution out of a django project\n"
    exit
  fi
  @ create_folders
}

function create_folders {
  mkdir -p "$APP_NAME"/static/"$APP_NAME"/css
  mkdir -p "$APP_NAME"/static/"$APP_NAME"/img
  mkdir -p "$APP_NAME"/static/"$APP_NAME"/js
  mkdir -p "$APP_NAME"/templates/"$APP_NAME"
  mkdir -p "$APP_NAME"/models/"$APP_NAME"
  mkdir -p "$APP_NAME"/views/"$APP_NAME"
  mkdir -p "$APP_NAME"/forms/"$APP_NAME"
}

function set_aliases {
  ALIASES_FILE=~/.`echo $SHELL | rev | cut -d '/' -f 1 | rev`rc
  IS_ALIASES=`cat $ALIASES_FILE | grep "python manage.py"`
  if [[ -z $IS_ALIASES ]]; then
    echo "alias pm='python manage.py'" >> "$ALIASES_FILE"
  fi
}

function script_help {
  printf "PLEASE CREATE HELP ME\n"
}

# Decorator
function @ {
  printf "$BOLD"
  printf "[$I] $1\n" | tr '_' ' ' | tr [a-z] [A-Z]
  printf "$RESET_COLOR"
  ((I++))
  eval "$1" "$2" "$3" "$4"
  # shellcheck disable=SC2181
  if [[ $? -ne 0 ]]; then
    printf "An error occurred, exiting ..."
    exit;
  fi
}

if [[ $1 != "new" || -z $2 ]]; then
   script_help;
   exit;
fi
I=0
check_python;
check_django;
if [[ $2 == "project" ]]; then
  @ create_project "$3"
elif [[ $2 == "app" ]]; then
  @ create_app "$3"
fi
set_aliases;
