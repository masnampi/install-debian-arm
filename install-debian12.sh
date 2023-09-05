#!/data/data/com.termux/files/usr/bin/bash
pkg install root-repo x11-repo
pkg install proot pulseaudio -y
debian=bookworm
termux-setup-storage
path=debian
if [ -d "$path" ]; then
        first=1
        echo "debian already downloaded !"
fi
tarfile="debian-rootfs.tar.xz"
if [ "$first" != 1 ];then
        if [ ! -f $tarfile ]; then
                echo "setup rootfs . . ."
                case `dpkg --print-architecture` in
                aarch64)
                        archurl="arm64v8" ;;
                arm*)
                        archurl="arm32v7" ;;
                x86)
                        archurl="i386" ;;
                x86_64)
                        archurl="amd64" ;;
                *)
                        echo "unknown architecture"; exit 1 ;;
                esac
                wget "https://github.com/debuerreotype/docker-debian-artifacts/blob/dist-${archurl}/${debian}/rootfs.tar.xz?raw=true" -O $tarfile
        fi
        cur=`pwd`
        mkdir -p "$path"
        cd "$path"
        echo "decompressing rootfs . . ."
        proot --link2symlink tar -xf ${cur}/${tarfile}||:
        cd "$cur"
   fi
   echo "debian" > ~/"$path"/etc/hostname
   echo "127.0.0.1 localhost" > ~/"$path"/etc/hosts
   echo "nameserver 8.8.8.8" > ~/"$path"/etc/resolv.conf
mkdir -p $path/binds
bin=.debian
linux=debian
echo "writing launch script . . ."
cat > $bin <<- EOM
#!/bin/bash
cd \$(dirname \$0)
## unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
command="proot"
command+=" --kill-on-exit"
command+=" --link2symlink"
command+=" -0"
command+=" -r $path"
if [ -n "\$(ls -A $path/binds)" ]; then
    for f in $path/binds/* ;do
      . \$f
    done
fi
command+=" -b /dev"
command+=" -b /proc"
command+=" -b $path/root:/dev/shm"
## uncomment the following line to have access to the home directory of termux
#command+=" -b /data/data/com.termux/files/home:/root"
## uncomment the following line to mount /sdcard directly to /
command+=" -b /sdcard"
command+=" -w /root"
command+=" /usr/bin/env -i"
command+=" HOME=/root"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
command+=" TERM=\$TERM"
command+=" LANG=C.UTF-8"
command+=" /bin/bash --login"
com="\$@"
if [ -z "\$1" ];then
    exec \$command
else
    \$command -c "\$com"
fi
EOM
   #Fixing shebang of $linux"
   termux-fix-shebang $bin
   #Making $linux executable"
   chmod +x $bin
   #Removing image for some space"
   rm $tarfile
#Sound Fix
echo '#!/bin/bash
pulseaudio --start \
    --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" \
    --exit-idle-time=-1
bash .debian' > $PREFIX/bin/$linux
chmod +x $PREFIX/bin/$linux
   clear
   echo ""
   echo "updateing debian . . ."
   echo ""
echo "#!/bin/bash
apt update && apt upgrade -y
apt install apt-utils dialog nano vim -y
rm -rf ~/.bash_profile
exit" > $path/root/.bash_profile
bash $linux
   clear
   echo ""
   echo "type debian to start Debian !"
   echo ""
rm install-debian12.sh
