cd /opt/

#HTTPSCREENSHOT:
git clone https://github.com/breenmachine/httpscreenshot.git
cd /httpscreenshot/
./install-dependencies.sh

#NOSQLMAP:
git clone https://github.com/tcstool/NoSQLMap.git

#CMSMAP:
git clone https://github.com/Dionach/CMSmap.git

#RANGER:
git clone https://github.com/ranger/ranger.git
cd ./ranger/
sudo make install

#CONKY:
sudo apt-get install conky-all

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

# Conky2
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

