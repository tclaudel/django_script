**Django Creator**

git clone https://github.com/tclaudel/django_script
mv django_script /usr/local/bin
echo "alias django_init='/usr/local/bin/django_script/django.sh'" >> "~/.`echo $SHELL | rev | cut -d '/' -f 1 | rev`rc"
source ~/.zshrc