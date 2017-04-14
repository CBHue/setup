#!/bin/bash

##### (Cosmetic) Colour output
RED="\033[01;31m"      # Issues/Errors
GREEN="\033[01;32m"    # Success
YELLOW="\033[01;33m"   # Warnings/Information
BLUE="\033[01;34m"     # Heading
BOLD="\033[01;01m"     # Highlight
RESET="\033[00m"       # Normal

#Wallpaper
curl --progress -k -L "http://www.kali.org/images/wallpapers-01/kali-wp-june-2014_1920x1080_A.png" > /usr/share/wallpapers/BG.png

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
EOF

##### Installing chromium
echo -e "\n $GREEN[+]$RESET Installing chromium"
apt-get -y -qq install chromium

##### Installing conky
echo -e "\n $GREEN[+]$RESET Installing conky ~ GUI desktop monitor"
apt-get -y -qq install conky

#--- Configure conky
file=/root/.conkyrc_right; [ -e "$file" ] && cp -n $file{,.bkup}
cat <<EOF > "$file"
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
#${color green}$time
#${scroll 16 $nodename - $sysname $kernel on $machine | }
${color white}System $hr
${color green}Hostname: ${color red}${exec whoami} @ $nodename
${color green}Kernel:   $kernel
${color green}Uptime:$color   $uptime

${color white}Processor $hr
${color green}CPU Freq:$color  $freq MHz
${color green}CPU Usage:$color $cpu% ${cpubar 4}
${color green}Name              PID   CPU%   MEM%
${color green} ${top name 1} ${top pid 1} ${top cpu 1} ${top mem 1}
${color green} ${top name 2} ${top pid 2} ${top cpu 2} ${top mem 2}
${color green} ${top name 3} ${top pid 3} ${top cpu 3} ${top mem 3}
${color green} ${top name 4} ${top pid 4} ${top cpu 4} ${top mem 4}
${color green}Processes:$color $processes  ${color}Running:$color $running_processes

${color white}Memory $hr
${color green}${memgraph 23,350 000000 800000 -t}
${color green}RAM Usage:$color  $mem/$memmax - $memperc% 
${membar 4}
${color green}Swap Usage:$color $swap/$swapmax - $swapperc% 
${swapbar 4}

${color white}Storage $hr
${color green}File systems:
 / $color${fs_used /}/${fs_size /} ${fs_bar 6 /}

${color white}Networking $hr
#${color green}Public IP: ${color red}${execi 10 dig +short myip.opendns.com @resolver1.opendns.com}
# Start eth0
${if_up eth0}${color green}eth0 $color ${addr eth0}
${color green}eth0 $color ${exec ifconfig | grep ether | cut -d" " -f10} 

${color green}Upload Gateway: $color${upspeedf eth0}Kb/s
${color green}${upspeedgraph eth0 20,350 0000ff ff0000 -t}
${color green}Download Gateway: $color${downspeedf eth0}Kb/s
${color green}${downspeedgraph eth0 20,350 0000ff ff0000 -t}${endif}
# End eth0
# start eth1
${if_up eth1}${color green}eth1  $color ${addr eth1}
${color green}eth1 $color ${endif}
# Start tap0
${if_up tap0}${color green}tap0  $color ${addr tap0}

${color green}Upload Gateway: $color${upspeedf tap0}Kb/s
${color green}${upspeedgraph tap0 20,350 0000ff ff0000 -t}
${color green}Download Gateway: $color${downspeedf tap0}Kb/s
${color green}${downspeedgraph tap0 20,350 0000ff ff0000 -t}${endif}
# End tap0

#${color white}Listening TCP:
#${color green}${execi 10 netstat -anlp | grep LISTEN | grep -v ING | awk -F" " '{printf "%-5s %-15s %-15s %-15s\n", $1, $4, $5, $7}'}

#${color white}Listening UDP:
#${color green}${execi 10 netstat -anulp | egrep -v "udp6|Proto|\(servers|ESTABLISHED" | awk -F" " '{printf "%-5s %-15s %-15s %-15s\n", $1, $4, $5, $6}'}
EOF

cat <<EOF > /root/.conkyrc_left
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
${color white}Networking $hr
# Start eth0
${if_up eth0}${color green}eth0 $color ${addr eth0}
${color green}eth0 $color ${exec ifconfig eth0| grep ether | cut -d" " -f10 } ${endif}
#
# Start wlan0
${if_up wlan0}
${color green}wlan0 $color ${exec iwgetid -r} 
${color green}wlan0 $color ${addr wlan0}
${color green}wlan0 $color ${exec ifconfig wlan0| grep ether | cut -d" " -f10 } 
#
${color white}Upload Gateway: $color${upspeedf wlan0}Kb/s
${color green}${upspeedgraph wlan0 20,350 0000ff ff0000 -t}
${color white}Download Gateway: $color${downspeedf wlan0}Kb/s
${color green}${downspeedgraph wlan0 20,350 0000ff ff0000 -t}
${endif}
#
# Start ra0
${if_up ra0}
${color green}ra0 $color ${exec iwgetid -r} 
${color green}ra0 $color ${addr ra0}
${color green}ra0 $color ${exec ifconfig ra0| grep ether | cut -d" " -f10 } 

${color white}Upload Gateway: $color${upspeedf ra0}Kb/s
${color green}${upspeedgraph ra0 20,350 0000ff ff0000 -t}
${color white}Download Gateway: $color${downspeedf ra0}Kb/s
${color green}${downspeedgraph ra0 20,350 0000ff ff0000 -t}
${endif}
# Start tun0
${if_up tun0}${color green}tun0 $color ${addr tun0} ${endif}

${color white}Listening TCP:
${color green}${execi 10 netstat -anlp | grep LISTEN | grep -v ING | awk -F" " '{printf "%-5s %-15s %-15s %-15s\n", $1, $4, $5, $7}'}

${color white}Listening UDP:
${color green}${execi 10 netstat -anulp | egrep -v "udp6|Proto|\(servers|ESTABLISHED" | awk -F" " '{printf "%-5s %-15s %-15s %-15s\n", $1, $4, $5, $6}'}
EOF

mkdir -p /root/.config/autostart/
cat <<EOF > "/root/.config/autostart/conkyrc_right.desktop"
[Desktop Entry]
Type=Application
Exec=/usr/bin/conky -c /root/.conkyrc_right
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
Exec=/usr/bin/conky -c /root/.conkyrc_left
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Conky2
Comment=<optional comment>
EOF

##### Installing Python ftp
echo -e "\n $GREEN[+]$RESET Installing Python FTPdlib"
apt-get -y -qq install python-pyftpdlib

##### Installing libreoffice
echo -e "\n $GREEN[+]$RESET Installing libreoffice ~ GUI office suite"
apt-get -y -qq install libreoffice

##### Installing flash
echo -e "\n $GREEN[+]$RESET Installing flash ~ multimedia web plugin"
apt-get -y -qq install flashplugin-nonfree
update-flashplugin-nonfree --install

##### Installing veil framework
echo -e "\n $GREEN[+]$RESET Installing veil framework ~ bypasses anti-virus"
apt-get -y -qq install veil
pip install symmetricjsonrpc
touch /etc/veil/settings.py
#/usr/share/veil-evasion/setup --silent ~ https://bugs.kali.org/view.php?id=2365
#sed -i 's/TERMINAL_CLEAR=".*"/TERMINAL_CLEAR="false"/' /etc/veil/settings.py

###### Installing shellter
echo -e "\n $GREEN[+]$RESET Installing shellter ~ dynamic shellcode injector"
apt-get -y -qq install shellter

###### Installing the backdoor factory
echo -e "\n $GREEN[+]$RESET Installing backdoor factory ~ bypasses anti-virus"
apt-get -y -qq install backdoor-factory

###### Installing the Backdoor Factory Proxy (BDFProxy)
echo -e "\n $GREEN[+]$RESET Installing backdoor factory ~ patches binaries files during a MITM"
git clone git://github.com/secretsquirrel/BDFProxy.git /opt/bdfproxy-git/
pushd /opt/bdfproxy-git/ >/dev/null
git pull
popd >/dev/null

##### Installing CMSmap
echo -e "\n $GREEN[+]$RESET Installing CMSmap ~ CMS detection"
apt-get -y -qq install git
git clone git://github.com/Dionach/CMSmap.git /opt/cmsmap-git/
pushd /opt/cmsmap-git/ >/dev/null
git pull
popd >/dev/null

#HTTPSCREENSHOT:
echo -e "\n $GREEN[+]$RESET Installing HTTP screenshot"
git clone git://github.com/breenmachine/httpscreenshot.git /opt/httpscreenshot/
pushd /opt/httpscreenshot/ >/dev/null
./install-dependencies.sh
popd >/dev/null
 
#NOSQLMAP:
echo -e "\n $GREEN[+]$RESET Installing NoSQLMap"
git clone https://github.com/tcstool/NoSQLMap.git /opt/NoSQLMap/

#RANGER:
git clone https://github.com/ranger/ranger.git /opt/ranger/
pushd /opt/ranger/ >/dev/null
make install
popd >/dev/null

##### Installing droopescan
echo -e "\n $GREEN[+]$RESET Installing droopescan ~ Drupal vulnerability scanner"
apt-get -y -qq install git
git clone git://github.com/droope/droopescan.git /opt/droopescan-git/
pushd /opt/droopescan-git/ >/dev/null
git pull
popd >/dev/null


