#!/bin/bash

# Let Me Insist: n30m1nd

# Error log
err_log="errors.log"
# This next line prints every error to the err_log file
exec 2> $err_log

# OS Information
printf "[+] Retrieving OS info...\n"
os_log="os-info.log"
touch $os_log 

# Distribution info checks
    printf "[+] Retrieving distribution type...\n"

    printf "==Distribution info==\n" >> $os_log
    cat /etc/issue >> $os_log || printf "[-] No issue file found\n:/"
    for f in /etc/*-release; do
        cat "$f" >> $os_log || printf "[-] $f not found...\n"
    done

# Kernel info checks
    printf "[+] Retrieving kernel version\n"

    printf "\n==Kernel info==\n" >> $os_log
    cat /proc/version >> $os_log || printf "[-] \tNo /proc/version found :'(\n"
    if [ uname ]; then
		uname -a >> $os_log
    	uname -mrs >> $os_log
	else
		printf "[-] \tNo uname command, trying rpm...\n"
	    rpm -q kernel >> $os_log || printf "[-] rpm also failed... wut\n"
	fi
	if [ dmesg ]; then
    	dmesg | grep Linux >> $os_log
	else
		printf "[-] \tNo dmesg command...\n"
	fi
	if [ -e /boot ]; then
		ls /boot | grep vmlinuz- >> $os_log
	else
		printf "[-] \tNo /boot dir...\n"
	fi

# Retrieving about enviromental variables 
    printf "[+] Retrieving env variables info\n"
	
    printf "\n==Environmental variables==\n" >> $os_log

    cat /etc/profile >> $os_log || printf "[-] \tNo /etc/profile\n"

    cat /etc/bashrc >> $os_log || printf "[-] \tNo /etc/bashrc\n"
    
    cat ~/.bash_profile >> $os_log || printf "[-] \tNo ~/.bash_profile\n"
    cat ~/.bashrc >> $os_log || printf "[-] \tNo ~/.bashrc\n"
    cat ~/.bash_logout >> $os_log || printf "[-] \tNo ~/.bash_logout\n"
    env >> $os_log || printf "[-] \tenv command failed\n"
    set >> $os_log || printf "[-] \tset command failed\n"

# Retrieving printer info
printf "[+] Retrieving printers info\n"
printers_log="printers.log"
lpstat -a >> $printers_log 

# Applications & services
printf "[+] Retrieving apps and services info...\n"
appnsrvcs_log="applications_services.log"
touch $appnsrvcs_log 
# Services running and their privileges
{
    printf "\n==Services & privileges==\n"
    ps aux
    ps -ef
    top -bn1
    cat /etc/services
    printf "\n==RUN BY ROOT==\n"
    ps aux | grep root
    ps -ef | grep root
    printf "\n==EOF ROOT CMDS==\n"

# Installed apps and versions
    printf "\n==Apps & versions==\n"
    ls -alh /usr/bin/
    ls -alh /sbin/
    dpkg -l
    rpm -qa
    ls -alh /var/cache/apt/archivesO
    ls -alh /var/cache/yum/

# Configurations info
    printf "\n==Configurations info==\n"
    cat /etc/syslog.conf
    cat /etc/chttp.conf
    cat /etc/lighttpd.conf
    cat /etc/cups/cupsd.conf
    cat /etc/inetd.conf
    cat /etc/apache2/apache2.conf
    cat /etc/my.conf
    cat /etc/httpd/conf/httpd.conf
    cat /opt/lampp/etc/httpd.conf
    ls -aRl /etc/ | awk '$1 ~ /^.*r.*'
    printf "\n==.old config files==\n"
    ls -aRl /etc/ | grep ".old$"
# Scheduled jobs
    printf "\n==CRON jobs==\n"
    crontab -l
    ls -alh /var/spool/cron
    ls -al /etc/ | grep cron
    ls -al /etc/cron*
    cat /etc/cron*
    cat /etc/at.allow
    cat /etc/at.deny
    cat /etc/cron.allow
    cat /etc/cron.deny
    cat /etc/crontab
    cat /etc/anacrontab
    cat /var/spool/cron/crontabs/root
} >> $appnsrvcs_log 

# Communication and networking
# NICs (Network Interface Cards)
printf "[+] Network checks \n"
network_log="network.log"
{
    printf "==NETWORK INTERFACES==\n"
    /sbin/ifconfig -a
    cat /etc/network/interfaces
    cat /etc/sysconfig/network
    printf "\n==CONFIGURATION SETTINGS==\n"
    cat /etc/resolv.conf
    cat /etc/sysconfig/network
    cat /etc/networks
    iptables -L
    hostname
    dnsdomainname
    printf "\n==NETWORK CONNECTIONS==\n"
    lsof -i
    printf "\n==NETSTAT==\n"
    netstat -punta
    printf "\n==USERS LOGGED IN==\n"
    w

} > $network_log

# OSINT
printf "[+] OSINT Checks \n"
osint_log="osint.log"
{
    printf "==WHO AM I==\n"
    whoami
    id
    who
    printf "==LIST OF USERS==\n"
    cat /etc/passwd
    printf "==LAST USERS==\n"
    last
    printf "==LAST MODIFIED HISTORY FILES OF ALL USERS==\n"
    ls -latr /home/*/.*history
    printf "\n==SUPER USERS==\n"
    grep -v -E "^#" /etc/passwd | awk -F: '$3 == 0 { print $1}'
    cat /etc/sudoers
} > $osint_log

# USER INFORMATION
printf "[+] User information checks \n"
user_log="user_information.log"
{
    printf "==USER HISTORY==\n"
    cat ~/.bash_history
    cat ~/.nano_history
    cat ~/.atftp_history
    cat ~/.mysql_history
    cat ~/.php_history
    printf "==USER INFORMATION==\n"
    cat ~/.bashrc
    cat ~/.profile
    cat /var/mail/root
    cat /var/spool/mail/root
    printf "==USER KEYS==\n"
    ls -lR ~/.ssh/
    ls -lR /etc/ssh/
} > $user_log

# FILE SYSTEM & LOGS
printf "[+] File system & logs \n"
fs_and_logs="filesystem_and_logs.log"
{
    printf "==LAST 20 MODIFIED LOGS==\n"
    ls -ltr /var/log/*log | tail -n20
    printf "==WEBSERVICES HIDDEN FILES==\n"
    ls -alhR /var/www/
    ls -alhR /srv/www/htdocs/
    ls -alhR /usr/local/www/apache22/data/
    ls -alhR /opt/lampp/htdocs/
    ls -alhR /var/www/html/
    printf "\n==FSTAB==\n"
    cat /etc/fstab
    printf "\n==WORLD WRITABLE OR EXECUTABLE==\n"
    find / -writable -type d 
    find / -perm -222 -type d
    find / -perm -o w -type d
    find / -perm -o x -type d
    find / \( -perm -o w -perm -o x \) -type d
    printf "\n==WORLD WRITABLE FILES==\n"
    find / -xdev -type d \( -perm -0002 -a ! -perm -1000 \) -print
    printf "\n==FILES WITHOUT OWNER==\n"
    find / -xdev \( -nouser -o -nogroup \) -print
} > $fs_and_logs

# OPTIONAL #
# Passwords checks
printf "[i] Cleartext passwords search might take a while!\n"
printf "[?] Search for cleartext passwords (y/n)?: "
read answer
if [[ $answer =~ ^[Yy]$ ]]
then
    pw_log="passwords.log"
    touch $pw_log || printf "[+] Couldn't create $pw_log\n"
    {
        grep -rC 3 "pass\|password" / | grep -C 2 "user\|name\|username"
    } >> $pw_log
fi
printf "[+] All done...\n"
