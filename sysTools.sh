#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl_c(){
    echo -e "\n\n${redColour}[!] Exiting...${endColour}\n"
    tput cnorm && exit 1
}

# Ctrl + C
trap ctrl_c INT 
root_check="$(id -u) -ne 0"
backup_file="backup.txt"
cap="$(getcap -r / 2>/dev/null)"

#Variables Globales
important_files=("/etc/fstab"
"/etc/mtab"

"/etc/sysctl.conf"

"/etc/apt/sources.list"

"/etc/issue"

"/etc/issue.net"

"/etc/passwd"

"/etc/group"

"/etc/shadow"

"/etc/rc.local"

"/etc/hosts.equiv"

"/etc/aliases"

"/etc/mailname"

"/etc/hostname"

"/etc/network/interfaces"

"/etc/resolvconf/resolv.conf.d/base"

"/etc/resolvconf/resolv.conf.d/head"

"/etc/resolvconf/resolv.conf.d/original"

"/etc/passwd"

"/etc/group"

"/etc/shadow"

"/etc/hosts"

"/etc/hostname"

"/etc/resolv.conf"

"/etc/hosts.allow"

"/etc/hosts.deny"

"/etc/ssh/sshd_config"

"/etc/sudoers"

"/etc/crontab"
)



function helpPanel(){
  echo -e "\t${yellowColour}[+]${endColour}${grayColour} Here you have all parameters you can use: \n${endColour}"
  echo -e "\t${purpleColour}-l)${endColour}${grayColour} Lists the 30 most important files in the system. \n${endColour}"
  echo -e "\t${purpleColour}-c)${endColour}${grayColour} Backs up all files considered important. \n${endColour}"
  echo -e "\t${purpleColour}-h)${endColour}${grayColour} Help Panel \n${endColour}"
  echo -e "\t${purpleColour}-k)${endColour}${grayColour} Lists the capabilities present in the system \n${endColour}"
  echo -e "\t${purpleColour}-u)${endColour}${grayColour} Lists the system users. \n${endColour}"
  echo -e "\t${purpleColour}-s)${endColour}${grayColour} Lists the files with special permissions (SUID, SGUID) present in the system. \n${endColour}"
  echo -e "\t${purpleColour}-p)${endColour}${grayColour} Lists the open ports on the machine. \n${endColour}"
  echo -e "\t${purpleColour}-n)${endColour}${grayColour} Scans the machines whithin the local network. \n${endColour}"
  echo -e "\t${purpleColour}-a)${endColour}${grayColour} Executes all the tool options. \n${endColour}"
  }


#Functions of the program parameters
# -l
# Array to store the files not found
not_found_files=()


#Verify whether the list of important files contains items
function l_option(){
if [ ${#important_files[@]} -gt 0 ]; then
    # Mostrar el contenido de cada archivo
    for file in "${important_files[@]}"; do
        if [ -f "$file" ]; then
            echo -e "\n ${greenColour}[+]${endColour}${yellowColour}Content of: $file:${endColour}\n"
            cat "$file"
            echo -e "\n${turquoiseColour}------------------------------\n"
			cat "$file" >> "$backup_file"
        else
            not_found_files+=("$file")
        fi
    done

    if [ ${#not_found_files[@]} -gt 0 ]; then
        echo -e "\n${greenColour}[+]${endColour}${yellowColour}The following files were not found: ${endColour}"
        for file in "${not_found_files[@]}"; do
            echo "$file"
        done
    fi
else
    echo -e "${greenColour}[+]${endColour}${redColour} No important files were found.${endColour}"
fi
}

#-k
function k_option(){
if [ -n "$cap" ]; then
    echo -e "\n ${greenColour}[+]${endColour}${yellowColour}Capabilities found: ${endColour}\n"
    echo -e "$cap"
    echo -e "\n ${greenColour}[+]${endColour}${yellowColour} Files and directories with capabilities: ${endColour}\n"
    ls -l $cap 2>/dev/null
else
    echo -e "\n ${greenColour}[!]${endColour}${redColour} No capabilities were found in the system.${endColour}\n"
fi
}

#-u
function u_option(){
	if [ "$(id -u)" -ne 0 ]; then
	   echo -e "${redColour}[+]${endColour}${greenColour} You need root permisissions${endColour}\n"
	   exit 1
	fi

	echo -e "${greenColour}[+]${endColour}${yellowColour} Users found on the system:${endColour}\n"
	awk -F: '{ print $1 }' /etc/passwd

}

#-s
function s_option() {
    sgid=$(find / -type f -perm /2000 2>/dev/null)
    sticky_bit=$(find / -type d -perm /1000  2>/dev/null)
    suid=$(find / -type f -perm /4000 2>/dev/null)

echo -e "\n${greenColour}[+]${endColour}${yellowColour}SGID files found: ${endColour}\n"
echo "$sgid"
echo -e "\n${greenColour}[+]${endColour}${yellowColour}Sticky bit files found: ${endColour}\n"
echo "$sticky_bit"
echo -e "\n${greenColour}[+]${endColour}${yellowColour}SUID files found: ${endColour}\n"
echo "$suid"
}

function p_option(){
	for port in $(seq 1 65535); do
	(echo '' > /dev/tcp/127.0.0.1/$port) 2>/dev/null && echo -e "${greenColour}[+]${endColour}${yellowColour} $port - OPEN ${endColour}" &
	done; wait
}

function n_option(){
	for pp in $(seq 1 254); do
	timeout 1 bash -c "ping -c 1 192.168.1.$pp &>/dev/null" && echo -e "${greenColour}[+]${endColour} ${yellowColour}Host 192.168.1.$pp - ACTIVE ${endColour}" &
	done; wait
}

#Indicadores
declare -i parameter_counter=0

#Verify if a parameter is gived to the program
if [ $# -eq 0 ]; then
	echo -e " \n${redColour}[+]${endColour} ${grayColor}You have to give the program any parameter ${endColour}\n" && helpPanel
	exit 1
fi


while getopts "hlckuspna" opt; do 
  case $opt in
    l) let parameter_counter+=1;;
    c) let parameter_counter+=2;;
    k) let parameter_counter+=3;;
    u) let parameter_counter+=4;;
    s) let parameter_counter+=5;;
    p) let parameter_counter+=6;;
    n) let parameter_counter+=7;;
    a) let parameter_counter+=8;;
    h) ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
	echo -e "\n${purpleColour}[+]${endColour} ${grayColour}Enumerating system files..${endColour}"
    l_option
elif [ $parameter_counter -eq 2 ]; then
    touch backup.txt
    l_option >> backup.txt
    echo -e "/n${purpleColor}[+]${endColour}${grayColor}Backup created in:${endColour} $backup_file"
    exit 0
elif [ $parameter_counter -eq 3 ]; then
	 echo -e "\n${purpleColour}[+]${endColour} ${grayColour}Looking for Capabilities on the system..${endColour}"
     k_option
elif [ $parameter_counter -eq 4 ]; then
	 echo -e "\n${purpleColour}[+]${endColour} ${grayColour}Enumerating users..${endColour}"
     u_option
elif [ $parameter_counter -eq 5 ]; then
	 echo -e "\n${purpleColour}[+]${endColour} ${grayColour}Enumerating SUID,SGID and Sticky bit files..${endColour}"
     s_option
elif [ $parameter_counter -eq 6 ]; then
    echo -e "\n${purpleColour}[+]${endColour} ${grayColour}Enumerating Ports Open..${endColour}"
    p_option
elif [ $parameter_counter -eq 7 ]; then
     echo -e "\n${purpleColour}[+]${endColour} ${grayColour}Enumerating hosts on your localnet..${endColour}"
    n_option
elif [ $parameter_counter -eq 8 ]; then
    l_option
    u_option
    s_option
    p_option
    n_option
    k_option
  else
  helpPanel
fi
