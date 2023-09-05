#!/bin/bash
#Get the necessary components
apt-get update
apt-get install udisks2 -y
echo " " > /var/lib/dpkg/info/udisks2.postinst
apt-mark hold udisks2
apt-get install sudo -y ; dpkg-reconfigure tzdata
apt-get install xfce4 xfce4-goodies xfce4-terminal parole -y
apt-get install tigervnc-standalone-server dbus-x11 -y
apt-get --fix-broken install
apt-get clean

echo ""
echo "adding user . . ."
echo ""
adduser anonymous
usermod -aG sudo anonymous
su - anonymous

#Setup the necessary files
mkdir -p ~/.vnc
echo "#!/bin/bash
export PULSE_SERVER=127.0.0.1
xrdb $HOME/.Xresources
startxfce4" > ~/.vnc/xstartup

echo "#!/bin/sh
export DISPLAY=:1
export PULSE_SERVER=127.0.0.1
rm -rf /run/dbus/dbus.pid
dbus-launch startxfce4" > /usr/local/bin/vncstart
echo "vncserver -geometry 1800x2880 -name remote-desktop :1" > /usr/local/bin/vncstart
echo "vncserver -kill :*" > /usr/local/bin/vncstop
chmod +x ~/.vnc/xstartup
chmod +x /usr/local/bin/*
clear
wget https://raw.githubusercontent.com/masnampi/install-debianarm/main/passwd -P .vnc/

echo ""
echo "installing firefox esr . . ."
echo ""
apt install firefox-esr -y
vncstart
sleep 5
DISPLAY=:1 firefox &
sleep 10
pkill -f firefox
vncstop
sleep 2

wget -O $(find ~/.mozilla/firefox -name *.default-esr)/user.js https://raw.githubusercontent.com/masnampi/install-debianarm/main/user.js

rm .vnc/passwd
   clear
   echo "use vnc command :"
   echo "   - vncstart"
   echo "   - vncstop"
rm de-xfce.sh