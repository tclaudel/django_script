#!/usr/bin/env bash

# SETTINGS
APP_NAME="intranet"



YELLOW="\033[0;33m"
RESET_COLOR="\033[0m"
RED="\033[0;31m"
BOLD="\033[1m"

function help() {
  printf "./django.sh in your project folder to use it\n
- ./django.sh norme to check norm with pycodestyle\n
- ./django.sh s or server to lunch server on localhost\n
- ./django.sh new model/form/view/template name\n  To create the correspondent file with the __init__.py\n
- ./django.sh new model/form/view/template subdir/name
  To also create the also the subdir\n"
}

function error() {
  # shellcheck disable=SC2059
  printf "$RED\nERROR : $1$RESET_COLOR\n"
  exit
}

function norme() {
    pycodestyle */*/*.py | grep -v migration
    NORM_ERRORS=$(pycodestyle */*/*.py | grep -v migration | wc -l)
    if [[ $NORM_ERRORS -ne 0 ]]; then
      printf "$RED\n%d errors detected\n$RESET_COLOR" "$NORM_ERRORS"
    fi
}

function create_model() {
  init_fd=./$APP_NAME/models/__init__.py
  CLASS=${FILE::-9}
  echo "from ."$(echo $PARENT_FOLDER | tr '/' '.')${FILE::-3}" import ${CLASS}" >> $init_fd
  echo "from django.db import models


class ${CLASS^}(models.Model):" >> $FILE_PATH
}

function create_form() {
  echo create_form
}

function create_view() {
  CLASS=${FILE::-8}
  init_fd=./$APP_NAME/views/__init__.py
  echo "from ."$(echo $PARENT_FOLDER | tr '/' '.')${FILE::-3}" import $CLASS" >> $init_fd
  echo "from django.shortcuts import render


def ${CLASS^}(request):
  return render(request, '$CLASS.html')" >> $FILE_PATH
}

function new() {
  TYPE=$2;
  if [[ ! $(ls | grep manage.py) ]]; then
    error "You are not in your project directory"
  fi
  case $TYPE in
    model | form | view | template)
    if [[ $3 == */* ]]; then
      PARENT_FOLDER=$( echo $3 | sed 's|\(.*\)/.*|\1|')"/";
      FILE=$(echo $3 | cut -c$((${#PARENT_FOLDER}+1))-);
    else
      FILE=$3;
    fi
    if [[ $FILE == *.py ]]; then
      FILE=${FILE::-3}
    elif [[ $FILE == *.html ]]; then
      FILE=${FILE::-5}
    fi
    if [[ $TYPE == "template" ]]; then
      FILE+=.html
    else
      FILE+="_"$TYPE.py
    fi
    DIR_PATH=$APP_NAME/$TYPE"s"/$PARENT_FOLDER
    FILE_PATH=$APP_NAME/$TYPE"s"/$PARENT_FOLDER$FILE
    mkdir -p "$DIR_PATH"
    touch "$FILE_PATH"
    case $TYPE in
      model)
        create_model $@;
      ;;
      form)
        create_form $@;
      ;;
      view)
        create_view $@;
      ;;
    esac
    ;;
  *)
    error "django new $TYPE does not match model, form, view, template";
    ;;
  esac
}

case $1 in
  norme)
    norme;
    ;;
  s | server)
    python manage.py runserver;
    ;;
  new)
    new $@;
    ;;
  help)
    help;
    ;;
  *)
    help $@;
    ;;
esac