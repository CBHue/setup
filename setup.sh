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
aptLIST=( 
	apt-transport-https
	backdoor-factory
	chromium
	conky
	crackmapexec
	eyewitness
	freerdp-x11
	git
	gobuster
	libreoffice
	python3-pip
	python-pyftpdlib
	realtek-rtl88xxau-dkms
	responder
	shellter
	snapd
	sublime-text
	terminator
	unicornscan
	veil
	virtualbox-guest-x11
)

# GitHub Installs #
easyGIT=(
	git://github.com/breenmachine/httpscreenshot.git
	git://github.com/Dionach/CMSmap.git
	git://github.com/droope/droopescan.git
	git://github.com/NetSPI/cmdsql.git
	git://github.com/secretsquirrel/BDFProxy.git
	https://github.com/BastilleResearch/mousejack.git
	https://github.com/byt3bl33d3r/DeathStar
	https://github.com/CBHue/prepList.git
	https://github.com/CBHue/ipListER.git
	https://github.com/CBHue/Recon-da.git
	https://github.com/Coalfire-Research/Doozer.git
	https://github.com/Coalfire-Research/java-deserialization-exploits.git
	https://github.com/carnal0wnage/carnal0wnage-code.git
	https://github.com/CoreSecurity/impacket.git
	https://github.com/danielmiessler/SecLists.git
	https://github.com/EmpireProject/Empire.git
	https://github.com/fireeye/SessionGopher.git
	https://github.com/foxglovesec/JavaUnserializeExploits.git
	https://github.com/frohoff/ysoserial.git
	https://github.com/funkandwagnalls/ranger.git
	https://github.com/leebaird/discover.git
	https://github.com/quentinhardy/odat.git
	https://github.com/quentinhardy/scriptsAndExploits.git
	https://github.com/rebootuser/LinEnum.git
	https://github.com/tcstool/NoSQLMap.git
	https://github.com/trustedsec/spraywmi.git
)

# Read command line arguments
for x in $( tr '[:upper:]' '[:lower:]' <<< "$@" ); do
  if [ "${x}" == "--distupgrade" ]; then
    distupgrade=true
  elif [ "${x}" == "--upgrade" ]; then
    upgrade=true
  elif [ "${x}" == "--visual" ]; then
    visual=true
  elif [ "${x}" == "--help" ]; then
    echo "--upgrade : apt-get upgrade"
    echo "--dsitupgrade : apt-get dist-upgrade"
    echo "--visual : set background and setup conky"
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
	# Wallpaper ... Assuming you pulled the paper as well
	wPaperDIR="$(dirname "$(readlink -f "$0")")/"
	wPaper="$(ls $wPaperDIR |sort -R | egrep "png|jpg" |tail -1)"

	if [ -f $wPaper ]; then
	  gsettings set org.gnome.desktop.background picture-uri file://${wPaperDIR}/${wPaper}
	  gsettings set org.gnome.desktop.background picture-options "stretched"

	  # Need to check which desktop you are using ...
	  #xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s ${wPaperDIR}/${wPaper}
	fi
	
	file=/root/.tmux.conf;
	cat <<EOF > "$file"
# TMUX 4 the WIN!!
unbind %
bind | split-window -h
bind - split-window -v

# Set status bar
set -g status-bg black
set -g status-fg white
set -g status-left-length 90
set -g status-right-length 60
set -g window-status-current-attr bold
set -g status-interval 60
set -g status-justify left
set -g status-left '#[fg=white]</ #(ifconfig eth0 | grep netmask | cut -d" " -f10) > '
set -g status-right '#[fg=blue]#S #[fg=white]%a %d %b %R ' 

# Highlight active window
set-window-option -g window-status-current-bg black 
set-window-option -g window-status-current-fg yellow 

# Set window notifications
setw -g monitor-activity on
set -g visual-activity on

# Automatically set window title
setw -g automatic-rename on
set-option -g set-titles on

# Histories
set -g history-limit 10000

# Copy mode
setw -g mouse on

# Use Alt-arrow keys without prefix key to switch panes
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# Shift arrow to switch windows
bind -n S-Left  previous-window
bind -n S-Right next-window
EOF

	#--- Configure conky
	file=/root/.conkyrc_right
	cat <<EOF > "/root/.conkyrc_right"
# Conky Right
background no
use_xft yes
xftalpha 0.6
own_window true
own_window_type desktop
own_window_argb_visual true
# 0 = transparent, 255 = solid
own_window_argb_value 160 
double_buffer yes
update_interval 1
#maximum_width 400
alignment top_right
#gap_x 50
gap_y 110
no_buffers yes
uppercase no
cpu_avg_samples 5
net_avg_samples 5
diskio_avg_samples 5
if_up_strictness address
draw_shades no
draw_outline no
draw_borders no
draw_graph_borders yes
default_color lightgray
default_shade_color red
default_outline_color green
short_units true
use_spacer none
xftfont DejaVu Sans Mono:size=10
TEXT
\${color white}System \$hr
\${color green}Hostname: \${color red}\${exec whoami} @ \$nodename
\${color green}Kernel:   \$kernel
\${color green}Uptime:\$color   \$uptime
\${color white}Processor \$hr
\${color green}CPU Freq:\$color  \$freq MHz
\${color green}CPU Usage:\$color \$cpu% \${cpubar 4}
\${color green}Name                      PID   CPU%   MEM%
\${color green} 1: \${top name 1} \${top pid 1} \${top cpu 1} \${top mem 1}
\${color green} 2: \${top name 2} \${top pid 2} \${top cpu 2} \${top mem 2}
\${color green} 3: \${top name 3} \${top pid 3} \${top cpu 3} \${top mem 3}
\${color green} 4: \${top name 4} \${top pid 4} \${top cpu 4} \${top mem 4}
\${color green} 5: \${top name 5} \${top pid 5} \${top cpu 5} \${top mem 5}
\${color green} 6: \${top name 6} \${top pid 6} \${top cpu 6} \${top mem 6}
\${color green} 7: \${top name 7} \${top pid 7} \${top cpu 7} \${top mem 7}
\${color green}Processes:\$color \$processes  \${color}Running:\$color \$running_processes
\${color white}Memory \$hr
\${color green}\${memgraph 23,350 000000 800000 -t}
\${color green}RAM Usage:\$color  \$mem/\$memmax - \$memperc% 
\${membar 4}
\${color green}Swap Usage:\$color \$swap/\$swapmax - \$swapperc% 
\${swapbar 4}
\${color white}Storage \$hr
\${color green}File systems: / \$color\${fs_used /}/\${fs_size /} \${fs_bar 6 /}
EOF

	cat <<EOF > "/root/.conkyrc_left"
# Conky Left
background no
use_xft yes
xftalpha 0.6
own_window true
own_window_type desktop
own_window_argb_visual true
# 0 = transparent, 255 = solid
own_window_argb_value 160 
double_buffer yes
update_interval 1
#maximum_width 400
alignment top_left
gap_x 60
gap_y 110
no_buffers yes
uppercase no
cpu_avg_samples 5
net_avg_samples 5
diskio_avg_samples 5
if_up_strictness address
draw_shades no
draw_outline no
draw_borders no
draw_graph_borders yes
default_color lightgray
default_shade_color red
default_outline_color green
short_units true
use_spacer none
xftfont DejaVu Sans Mono:size=10
TEXT
\${color white}Networking \$hr
# Start eth0
\${if_up eth0}\${color green}eth0 \$color \${addr eth0}
\${color green}eth0 \$color \${exec ifconfig eth0| grep ether | cut -d" " -f10 } \${endif}
#
# Start wlan0
\${if_up wlan0}
\${color green}wlan0 \$color \${exec iwgetid -r} 
\${color green}wlan0 \$color \${addr wlan0}
\${color green}wlan0 \$color \${exec ifconfig wlan0| grep ether | cut -d" " -f10 } 
#
\${color white}Upload Gateway: \$color\${upspeedf wlan0}Kb/s
\${color green}\${upspeedgraph wlan0 20,350 0000ff ff0000 -t}
\${color white}Download Gateway: \$color\${downspeedf wlan0}Kb/s
\${color green}\${downspeedgraph wlan0 20,350 0000ff ff0000 -t}
\${endif}
#
# Start ra0
\${if_up ra0}
\${color green}ra0 \$color \${exec iwgetid -r} 
\${color green}ra0 \$color \${addr ra0}
\${color green}ra0 \$color \${exec ifconfig ra0| grep ether | cut -d" " -f10 } 
\${color white}Upload Gateway: \$color\${upspeedf ra0}Kb/s
\${color green}\${upspeedgraph ra0 20,350 0000ff ff0000 -t}
\${color white}Download Gateway: \$color\${downspeedf ra0}Kb/s
\${color green}\${downspeedgraph ra0 20,350 0000ff ff0000 -t}
\${endif}
# Start tun0
\${if_up tun0}\${color green}tun0 \$color \${addr tun0} \${endif}
\${color white}Listening TCP:
\${color green}\${execi 10 netstat -anlp | grep LISTEN | grep -v ING | awk -F" " '{printf "%-5s %-15s %-15s %-15s\n", \$1, \$4, \$5, \$7}'}
\${color white}Listening UDP:
\${color green}\${execi 10 netstat -anulp | egrep -v "udp6|Proto|\(servers|ESTABLISHED" | awk -F" " '{printf "%-5s %-15s %-15s %-15s\n", \$1, \$4, \$5, \$6}'}
EOF

mkdir -p /root/.config/autostart/
cat <<EOF > "/root/.config/autostart/conkyrc_right.desktop"
[Desktop Entry]
Type=Application
Exec=/usr/bin/conky -q -c /root/.conkyrc_right
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Conky2
Comment=<optional comment>
EOF

	# Start up items
	cat <<EOF > "/root/.config/autostart/conkyrc_left.desktop"
[Desktop Entry]
Type=Application
Exec=/usr/bin/conky -q -c /root/.conkyrc_left
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Conky2
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

# Lets write to some config files 
################################################
file=/root/.bash_aliases;
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

##################################################
#
# start here
#
##################################################

# apt update
echo -e "\n $GREEN[+]$RESET Apptitude updates ..."
apt-get -qq update 

# Sources
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list

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
for i in ${aptLIST[@]}; do aptINSTALL $i; done
for i in ${easyGIT[@]}; do gitINSTALL $i; done

#
# snapd installs
#
echo -e "\n $GREEN[+]$RESET Configuring snap"
systemctl enable snapd.service
systemctl start snapd.service

echo -e "\n $GREEN[+]$RESET Installing powershell snap"
snap install powershell --classic

#
# Detailed Git Configurations #
#

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

# RANGER:
if [ ! -d /opt/ranger/ ]; then
	echo -e "\n $GREEN[+]$RESET Configuring Ranger"
	pushd /opt/ranger/ >/dev/null
	git pull
	bash ./setup.sh
	ln -s /usr/bin/ranger ./ranger
	popd >/dev/null
fi

#
# Pip installs
#
echo -e "\n $GREEN[+]$RESET Installing Webdav Server"
pip install cheroot wsgidav

#
# reboot? # 
#
echo -e "\n $GREEN[+]$RESET All Done ..."
echo -e "\n $YELLOW[+] I need to reboot ... \n$RED"
read -p " [!] READY ... ? [y]es [n]o ..." -n 3 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
 reboot
fi
