# Script to Install Debian 12 ARM on Termux
Script to install debian on android tablet

update your termux first :
```
pkg update && pkg upgrade -y
```


**step 1, run on termux :**
```
pkg install wget -y ; wget https://raw.githubusercontent.com/masnampi/install-debian-arm/main/install-debian12.sh ; chmod +x install-debian12.sh ; ./install-debian12.sh
```

**step 2, run inside debian :**
```
apt install wget -y ; wget https://raw.githubusercontent.com/masnampi/install-debian-arm/main/setup-xfce.sh ; chmod +x setup-xfce.sh ; ./setup-xfce.sh
```
