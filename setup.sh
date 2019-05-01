#!/bin/bash

################################################################################################################
#
# Kali no frils Setup Script
# Pulls favorite apt and git tools
#
# Use this if you want to --upgrade
# Use this if you want to --distupgrade 
#
#################################################################################################################

# Optional steps
distupgrade=false     #[ --distupgrade ]
upgrade=false         #[ --upgrade ]
visual=false	      #[--visual]

# Where did i get this from ?
RED="\033[01;31m"      # Issues/Errors
GREEN="\033[01;32m"    # Success
YELLOW="\033[01;33m"   # Warnings/Information
BLUE="\033[01;34m"     # Heading
BOLD="\033[01;01m"     # Highlight
RESET="\033[00m"       # Normal

# Apttitude installs
aptLIST=()
apt="/opt/setup/apt.lst"

if [[ -f "$apt" ]]; then
	while IFS= read -r line 
	do
		if [[ $line == \#* ]]; then
			continue
		fi
		aptLIST+=($line)
	done <"$apt"
fi

# GitHub Installs #
git="/opt/setup/git.lst"
easyGIT=()
if [[ -f "$git" ]]; then
	while IFS= read -r line 
	do
		if [[ $line == \#* ]]; then
			continue
		fi
		easyGIT+=($line)
	done <"$git"
fi

# Read command line arguments
for x in $( tr '[:upper:]' '[:lower:]' <<< "$@" ); do
	if [ "${x}" == "--distupgrade" ]; then
		distupgrade=true
	elif [ "${x}" == "--upgrade" ]; then
		upgrade=true
	elif [ "${x}" == "--visual" ]; then
		visual=true
	elif [ "${x}" == "--apt" ]; then
		apttitude=true
	elif [ "${x}" == "--git" ]; then
		gitHub=true
	elif [ "${x}" == "--apt" ]; then
		snapd=true
	elif [ "${x}" == "--apt" ]; then
		pip=true
	elif [ "${x}" == "--help" ]; then
		echo "--upgrade : apt-get upgrade"
		echo "--dsitupgrade : apt-get dist-upgrade"
		echo "--apttitude : apt Tools"
		echo "--snapd : snapd Tools"
		echo "--pip : Python Tools"
		echo "--gitHub : GitHub Tools"
		exit 1
	else
		echo -e ' '$RED'[!]'$RESET' Unknown option: '${x} 1>&2
		exit 1
	fi
done

#
# functions
#
function aptINSTALL {
	echo -e "\n $BLUE[+]$RESET Installing $1"
	apt-get -y -qq install $1 > /dev/null
}

function prettyInstall {
	# Lets write to some config files 
	################################################
	file=$HOME/.bash_aliases;

	# maybe a file merge here?
	#if [ ! -f $file ]; then

	cat <<EOF > "$file"
alias chrome="chromium --no-sandbox --user-data-dir /tmp --password-store=basic 2>/dev/null &"
alias chromeProxy="chromium --no-sandbox --user-data-dir /tmp --password-store=basic --proxy-server=127.0.0.1:8080 2>/dev/null &"
alias httpServer="ifconfig; python -m SimpleHTTPServer"
alias ftpServer="ifconfig; python -m pyftpdlib -p 21 -w"
alias soapui="/opt/SoapUI-5.2.1/bin/soapui.sh 2>/dev/null &"
alias pubIP="dig +short myip.opendns.com @resolver1.opendns.com"
alias src="source ~/.bashrc"
alias msfc="service postgresql start; msfconsole"

# Were going to override the promt ... Should be done in profile ... but oh well
PS1="\[\033[31m\][\[\033[36m\]\u\[\033[31m\]]\[\033[31m\]\h:\[\033[33;1m\]\w\[\033[m\] : "

EOF
#fi
	# Wallpaper ... Assuming you pulled the paper as well
	wPaperDIR="$(dirname "$(readlink -f "$0")")/BG/"
	wPaper="$(ls $wPaperDIR |sort -R | egrep "png|jpg" |tail -1)"

	if [ -f $wPaper ]; then
		if [[ "$XDG_CURRENT_DESKTOP" == "GNOME" ]]; then
			gsettings set org.gnome.desktop.background picture-uri file://${wPaperDIR}${wPaper}
			gsettings set org.gnome.desktop.background picture-options "stretched"
		fi
		if [[ "$XDG_CURRENT_DESKTOP" == "XFCE" ]]; then
			# Move panel-1 to the bottom
			xfconf-query --channel 'xfce4-panel' --property '/panels/panel-1/position' --set "p=8;x=0;y=0"
			# Move panel-2 top left
			xfconf-query --channel 'xfce4-panel' --property '/panels/panel-2/position' --set "p=0;x=0;y=0"
			# Reset Background
			xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s ${wPaperDIR}/${wPaper}
		fi
	fi
	
	# Move conky.conf to the users home dir
	cp "$(dirname "$(readlink -f "$0")")/conky_right.conf" "$HOME/.conky_right.conf" 
	cp "$(dirname "$(readlink -f "$0")")/conky_left.conf" "$HOME/.conky_left.conf" 

	# Start up items
	mkdir -p $HOME/.config/autostart/

	cat <<EOF > "$HOME/.config/autostart/conkyrc_right.desktop"
[Desktop Entry]
Type=Application
Exec=conky --daemonize --pause=5 --quiet --config=$HOME/.conky_right.conf
Name=Conky-right
Comment=<optional comment>
EOF

	cat <<EOF > "$HOME/.config/autostart/conkyrc_left.desktop"
[Desktop Entry]
Type=Application
Exec=conky --daemonize --pause=6 --quiet --config=$HOME/.conky_left.conf
Name=Conky-left
Comment=<optional comment>
EOF

}

function gitINSTALL {
	echo -e "\n $GREEN[+]$RESET Installing $1"
	a=${1%\.*}
	b=${a##*/}
	c=$1

	# Is this a new tool?
	if [ -d /opt/$b ]; then
		pushd /opt/$b >/dev/null	
		git pull
	else
		git clone $c /opt/$b
		pushd /opt/$b >/dev/null	
	fi

	if [ -e requirements.txt ]; then 
		pip -q install -r requirements.txt
		pip3 -q install -r requirements.txt
	fi

	if [ -e setup.py ]; then 
		pip -q install .
	fi

	popd >/dev/null
}

##################################################
#
# start here
#
##################################################

# regular update
if [ "$upgrade" == "true" ]; then
  apt-get -y -qq upgrade
else
  echo -e ' '$RED'[!]'$RESET' Skipping apt-get upgrade ... [--upgrade]' 1>&2
fi

# Dist Upgrade
if [ "$dist" == "true" ]; then
  apt-get -y -qq dist-upgrade --fix-missing
else
  echo -e ' '$RED'[!]'$RESET' Skipping apt-get dist-upgrade ... [--distupgrade]' 1>&2
fi

# install background?
if [ "$visual" == "true" ]; then
  prettyInstall
else
  echo -e ' '$RED'[!]'$RESET' Skipping visuals ... [--visual]' 1>&2
fi

# LEts get our tools
if [ "$apptitude" == "true" ]; then
	# apt update
	echo -e "\n $GREEN[+]$RESET Apptitude updates ..."
	apt-get -qq update 

	# Sources
	echo -e "\n $GREEN[+]$RESET Sublime key ..."
	wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | apt-key add -
	echo "deb https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list

	for i in ${aptLIST[@]}; do aptINSTALL $i; done
else
  echo -e ' '$RED'[!]'$RESET' Skipping Apptitude ... [--visual]' 1>&2
fi

#
# snapd installs
#
if [ "snapd" == "true" ]; then
	echo -e "\n $GREEN[+]$RESET Configuring snap"
	systemctl enable snapd.service
	systemctl start snapd.service

	echo -e "\n $GREEN[+]$RESET Installing powershell snap"
	snap install powershell --classic
else
  echo -e ' '$RED'[!]'$RESET' Skipping snapd ... [--visual]' 1>&2
fi
#
# Detailed Git Configurations #
#

if [ "$gitHub" == "true" ]; then
	for i in ${easyGIT[@]}; do gitINSTALL $i; done

	# Configure Powershell Empire
	# need to fix this ... it will never work the way it is ...
	if [ ! -d /opt/Empire/ ]; then
		echo -e "\n $GREEN[+]$RESET Configuring Powershel Empire"
		pushd /opt/Empire/ >/dev/null
		git pull
		export STAGING_KEY=RANDOM
		bash /opt/Empire/setup/install.sh
		popd >/dev/null
	fi 

	# HTTPSCREENSHOT:
	if [ ! -d /opt/httpscreenshot/ ]; then
		echo -e "\n $GREEN[+]$RESET Configuring HTTP screenshot"
		pushd /opt/httpscreenshot/ >/dev/null
		git pull
		bash /opt/httpscreenshot/install-dependencies.sh
		popd >/dev/null
	fi

else
  echo -e ' '$RED'[!]'$RESET' Skipping gitHub ... [--visual]' 1>&2
fi

#
# Pip installs
#
if [ "$pip" == "true" ]; then
	echo -e "\n $GREEN[+]$RESET Installing Webdav Server"
	pip install cheroot wsgidav
else
  echo -e ' '$RED'[!]'$RESET' Skipping pip ... [--visual]' 1>&2
fi
#
# reboot? # 
#
echo -e "\n $GREEN[+]$RESET All Done ..."
echo -e "\n $YELLOW[+] I need to reboot ... \n$RED"
read -p " [!] READY ... ? [y]es [n]o ..." -n 3 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
 reboot
fi
