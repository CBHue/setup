#!/bin/bash

################################################################################################################
#
# ubuntu no frils Setup Script
# Pulls favorite apt and git tools
#
# Use this if you want to --upgrade
# Use this if you want to --distupgrade 
#
# https://github.com/CBHue
#
#################################################################################################################

# Where did i get this from ?
RED="\033[01;31m"      # Issues/Errors
GREEN="\033[01;32m"    # Success
YELLOW="\033[01;33m"   # Warnings/Information
BLUE="\033[01;34m"     # Heading
BOLD="\033[01;01m"     # Highlight
RESET="\033[00m"       # Normal

aptLIST=()
easyGIT=()

display_usage() {
	echo
	echo "Usage: $0"
	echo
	echo " -h, --help   Display usage instructions"
	echo " --upgrade : apt-get upgrade"
	echo " --distupgrade : apt-get dist-upgrade"
	echo " --visual : background, conky, etc"
	echo " --apt : apt Tools"
	echo " --snapd : snapd Tools"
	echo " --pip : Python Tools"
	echo " --gitHub : GitHub Tools"
	echo
	echo " Install all Tools"
	echo " -----------------"
	echo " $0 --visual --apt --snapd --pip --gitHub"
	echo " $0 --upgrade --visual --apt --snapd --pip --gitHub"
	echo
}

if [ "$#" -eq 0 ] ; then
	display_usage
	exit 1
fi

argument=$@
for a in $argument; do 
	case $a in
		-h|--help)
			display_usage
		;;
		-u|--upgrade)
			echo -e  ''$GREEN'[+]'$RESET' queuing upgrade'
			upgrade=true
			reboot=true
		;;
		-d|--distupgrade)
			echo -e  ''$GREEN'[+]'$RESET' queuing distupgrade'
			distupgrade=true
			reboot=true
		;;
		-v|--visual)
			echo -e  ''$GREEN'[+]'$RESET' queuing visual'
			visual=true
		;;
		-a|--apt)
			echo -e  ''$GREEN'[+]'$RESET' queuing aptitude installs'
			aptitude=true
			# Load apt.lst
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
		;;
		-s|--snapd)
			echo -e  ''$GREEN'[+]'$RESET' queuing snapd installs'
			snapd=true
		;;
		-p|--pip)
			echo -e  ''$GREEN'[+]'$RESET' queuing pip intsalls'
			pip=true
		;;
		-g|--gitHub)
			echo -e  ''$GREEN'[+]'$RESET' queuing gitHub'
			gitHub=true
			git="/opt/setup/git.lst"
			if [[ -f "$git" ]]; then
			while IFS= read -r line 
			do
				if [[ $line == \#* ]]; then
					continue
				fi
				easyGIT+=($line)
			done <"$git"
			fi
		;;
		*)
			echo -e  ''$RED'[!]'$RESET' unknown option '$a
		;;
	esac
done

#
# functions
#

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
	wPaperDIR="$(dirname "$(readlink -f "$0")")/BG"
	wPaper="$(ls $wPaperDIR |sort -R | egrep "png|jpg" |tail -1)"

	if [ -f "$wPaperDIR/$wPaper" ]; then
		if [[ "$XDG_CURRENT_DESKTOP" == "GNOME" ]]; then
			gsettings set org.gnome.desktop.background picture-uri file://${wPaperDIR}/${wPaper}
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

function aptINSTALL {
	echo -e "\n $BLUE[+]$RESET Installing $1"
	apt-get -y -qq install $1 > /dev/null
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
	apt-get -qq update 
	apt-get -y --quiet upgrade
	echo -e "\n $GREEN[+]$RESET Done with upgrade installs ..."
else
  echo -e ''$RED'[!]'$RESET' Skipping apt-get upgrade ... [--upgrade]' 1>&2
fi

# Dist Upgrade
if [ "$dist" == "true" ]; then
	apt-get -qq update 
	apt-get -y --quiet dist-upgrade --fix-missing
	echo -e "\n $GREEN[+]$RESET Done with dist-upgrade ..."
else
  echo -e ''$RED'[!]'$RESET' Skipping apt-get dist-upgrade ... [--distupgrade]' 1>&2
fi

# install background?
if [ "$visual" == "true" ]; then
  prettyInstall
else
  echo -e ''$RED'[!]'$RESET' Skipping visual ... [--visual]' 1>&2
fi

# LEts get our tools
if [ "$aptitude" == "true" ]; then

	echo -e "\n $GREEN[+]$RESET aptitude updates ..."
	# Sources
	echo -e "\n $GREEN[+]$RESET Sublime key ..."
	wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | apt-key add -
	echo "deb https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list
	# apt update	
	apt-get -qq update 

	for i in ${aptLIST[@]}; do aptINSTALL $i; done
	echo -e "\n $GREEN[+]$RESET Done with aptitude installs ..."
else
	echo -e ''$RED'[!]'$RESET' Skipping aptitude ... [--apt]' 1>&2
fi

#
# snapd installs
#
if [ "$snapd" == "true" ]; then
	echo -e "\n $GREEN[+]$RESET Configuring snap"
	systemctl enable snapd.service
	systemctl start snapd.service

	echo -e "\n $GREEN[+]$RESET Installing powershell snap"
	snap install powershell --classic
	echo -e "\n $GREEN[+]$RESET Installing golang-go snap"
	snap install go --classic
	echo -e "\n $GREEN[+]$RESET Done with snap installs ..."
else
  echo -e ''$RED'[!]'$RESET' Skipping snapd ... [--snapd]' 1>&2
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

	echo -e "\n $GREEN[+]$RESET Done with gitHub installs ..."
else
	echo -e ''$RED'[!]'$RESET' Skipping gitHub ... [--gitHub]' 1>&2
fi

#
# Pip installs
#
if [ "$pip" == "true" ]; then
	echo -e "\n $GREEN[+]$RESET Installing Webdav Server"
	pip install cheroot wsgidav
else
  echo -e ''$RED'[!]'$RESET' Skipping pip ... [--pip]' 1>&2
fi

#
# All Done ...
#
echo -e "\n $GREEN[+]$RESET All Done ..."

#
# reboot? # 
#
if [ "$reboot" == "true" ]; then
	echo -e "\n $YELLOW[+] I need to reboot ... \n$RED"
	read -p " [!] READY ... ? [y]es [n]o ..." -n 3 -r
	if [[ $REPLY =~ ^[Yy]$ ]]; then
	 reboot
	fi
fi
