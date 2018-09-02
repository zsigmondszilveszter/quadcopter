# The remaining parts of the LFS book had to compile on an ARM proccesor
# I haven't managed to cross compile the remaining packages and the compiled packages are not eligible to boot up and compile and remaining parts.
# One more package is enough to boot up the new system and this is Util-linux
# Without Util-linux cannot fire up the new cross compiled system, therefore at this step had to move all the compiled stuff to an ARM platform,
# and compile the strictly neccessary package in order to boot up the new system on a native platform.
# Now we can follow the exact instructions from book.


# - I use a Raspberry pi3 for this -
# After you are logged in, make a temporary directory and copy the half-done system with RSYNC command
TMP_CLFS="/root/tmp_clfs_szilv"
REMOTE_CLFS="/mnt/armv6_clfs"
REMOTE_SD_CARD_BOOT="root@192.168.1.7:/run/media/szilveszter/BOOT"
REMOTE_SD_CARD_ROOT="root@192.168.1.7:/run/media/szilveszter/ROOT"
mkdir $TMP_CLFS
cd $TMP_CLFS

# create and mount some system file
mkdir -pv $TMP_CLFS/{dev,proc,sys,run}
mknod -m 600 $TMP_CLFS/dev/console c 5 1
mknod -m 666 $TMP_CLFS/dev/null c 1 3
mount -v --bind /dev $TMP_CLFS/dev
mount -vt devpts devpts $TMP_CLFS/dev/pts -o gid=5,mode=620
mount -vt proc proc $TMP_CLFS/proc
mount -vt sysfs sysfs $TMP_CLFS/sys
mount -vt tmpfs tmpfs $TMP_CLFS/run
if [ -h $TMP_CLFS/dev/shm ]; then
 mkdir -pv $TMP_CLFS/$(readlink $TMP_CLFS/dev/shm)
fi

# copy the half-done system
rsync -avP --numeric-ids --exclude=/dev --exclude=/run --exclude=/sys \
 --exclude=/proc --exclude=/ctools --exclude=/sources \
 --exclude=/tools root@192.168.1.199:$REMOTE_CLFS/* .
# copy source files
mkdir sources
cd sources
# run them ony by one
rsync -avP root@192.168.1.199:$REMOTE_CLFS/sources/bash-4.4.18.tar.gz .
# we have to extract them, because in chroot environment there is no tar yet
tar -xf bash-4.4.18.tar.gz
tar -xf util-linux-2.31.1.tar.xz
cd ..



# enter to the chroot environment
chroot ~/tmp_clfs_szilv

ln -svf /bin/bash /bin/sh
CORE_COUNT=$(nproc)

cd /sources



# First of all, we have to recompile bash, I don't know why,
# but with the cross-compiled version some compilations silently fails
#***********************************************************************************************
#>> Bash <<  
#tar -xf bash-4.4.18.tar.gz
cd bash-4.4.18


./configure --prefix=/usr \
 --docdir=/usr/share/doc/bash-4.4.18 \
 --without-bash-malloc \
 --with-installed-readline

make -j$CORE_COUNT
make install
mv -vf /usr/bin/bash /bin
exec /bin/bash --login +h


cd ..
rm -rf bash-4.4.18




#***********************************************************************************************
#>> Util-linux

exit # exit the chroot environment, there is no util-linux yet and util-linux cannot compile without util-linux installed(more precisely I couldnt)

tar -xf util-linux-2.31.1.tar.xz
cd util-linux-2.31.1

mkdir -pv /var/lib/hwclock

./configure ADJTIME_PATH=/var/lib/hwclock/adjtime \
 --docdir=/usr/share/doc/util-linux-2.31.1 \
 --disable-chfn-chsh \
 --disable-login \
 --disable-nologin \
 --disable-su \
 --disable-setpriv \
 --disable-runuser \
 --disable-pylibmount \
 --disable-static \
 --without-python \
 --without-systemd \
 --without-systemdsystemunitdir

make -j$CORE_COUNT
make install DESTDIR=$TMP_CLFS

cd ..
rm -rf util-linux-2.31.1



# now we have to make some othe configuration in order to we can boot up the new system and finish the compilation of remaining packages

# enter to the chroot environment
chroot ~/tmp_clfs_szilv

# shadow, enable and create root pw, etc.
pwconv
grpconv
passwd root


# inittab
cat > /etc/inittab << "EOF"
# Begin /etc/inittab
id:3:initdefault:
si::sysinit:/etc/rc.d/init.d/rc S
l0:0:wait:/etc/rc.d/init.d/rc 0
l1:S1:wait:/etc/rc.d/init.d/rc 1
l2:2:wait:/etc/rc.d/init.d/rc 2
l3:3:wait:/etc/rc.d/init.d/rc 3
l4:4:wait:/etc/rc.d/init.d/rc 4
l5:5:wait:/etc/rc.d/init.d/rc 5
l6:6:wait:/etc/rc.d/init.d/rc 6
ca:12345:ctrlaltdel:/sbin/shutdown -t1 -a -r now
su:S016:once:/sbin/sulogin
1:2345:respawn:/sbin/agetty --noclear tty1 9600
2:2345:respawn:/sbin/agetty tty2 9600
3:2345:respawn:/sbin/agetty tty3 9600
4:2345:respawn:/sbin/agetty tty4 9600
5:2345:respawn:/sbin/agetty tty5 9600
6:2345:respawn:/sbin/agetty tty6 9600
# End /etc/inittab
EOF

cat > /etc/sysconfig/clock << "EOF"
# Begin /etc/sysconfig/clock
UTC=1
# Set this to any options you might need to give to hwclock,
# such as machine hardware clock type for Alphas.
CLOCKPARAMS=
# End /etc/sysconfig/clock
EOF

# copy the compiled system to the SD card root partition
rsync -avP --numeric-ids --exclude=/dev --exclude=/run --exclude=/sys \
 --exclude=/proc --exclude=/ctools --exclude=/sources --exclude=/tools \
 root@192.168.1.7:$TMP_CLFS/* $REMOTE_SD_CARD_ROOT