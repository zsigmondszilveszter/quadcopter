## put this into the user's bash_profile
export CLFS_DIR=armv6_clfs
export LFS=/mnt/$CLFS_DIR 
export CORE_COUNT=3

export CLFS_FLOAT="hard"
export CLFS_FPU="vfpv2"
export CLFS_HOST="i686-cross-linux-gnu"
export CLFS_TARGET="arm-szilv-linux-gnueabihf"
export CLFS_ARCH="arm"
export CLFS_ARM_ARCH="armv6"

export CC="${CLFS_TARGET}-gcc"
export CXX="${CLFS_TARGET}-g++"
export AR="${CLFS_TARGET}-ar"
export AS="${CLFS_TARGET}-as"
export LD="${CLFS_TARGET}-ld"
export RANLIB="${CLFS_TARGET}-ranlib"
export READELF="${CLFS_TARGET}-readelf"
export STRIP="${CLFS_TARGET}-strip"
export CROSS_COMPILE=${CLFS_TARGET}-
export ARCH=${CLFS_ARCH}


# enter to the newly created temporary system and cross toolchain
mkdir -pv $LFS/{dev,proc,sys,run}
mknod -m 600 $LFS/dev/console c 5 1
mknod -m 666 $LFS/dev/null c 1 3
mount -v --bind /dev $LFS/dev
mount -vt devpts devpts $LFS/dev/pts -o gid=5,mode=620
mount -vt proc proc $LFS/proc
mount -vt sysfs sysfs $LFS/sys
mount -vt tmpfs tmpfs $LFS/run
if [ -h $LFS/dev/shm ]; then
 mkdir -pv $LFS/$(readlink $LFS/dev/shm)
fi

chroot "$LFS" /tools/bin/env -i \
 HOME=/root \
 TERM="$TERM" \
 PS1='(lfs chroot) \u:\w\$ ' \
 PATH=/tools/bin:/ctools/bin:/bin:/usr/bin:/sbin:/usr/sbin \
 /tools/bin/bash --login +h

mkdir -pv /{bin,boot,etc/{opt,sysconfig},home,lib/firmware,mnt,opt}
mkdir -pv /{media/{floppy,cdrom},sbin,srv,var}
install -dv -m 1777 /tmp /var/tmp
mkdir -pv /usr/{,local/}{bin,include,lib,sbin,src}
mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man}
mkdir -v /usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -v /usr/libexec
mkdir -pv /usr/{,local/}share/man/man{1..8}
case $(uname -m) in
 x86_64) mkdir -v /lib64 ;;
esac
mkdir -v /var/{log,mail,spool}
ln -sv /run /var/run
ln -sv /run/lock /var/lock
mkdir -pv /var/{opt,cache,lib/{color,misc,locate},local}

ln -sv /tools/bin/{bash,cat,dd,echo,ln,pwd,rm,stty} /bin
ln -sv /tools/bin/{install,perl} /usr/bin
ln -sv /tools/lib/libgcc_s.so{,.1} /usr/lib
ln -sv /tools/lib/libstdc++.{a,so{,.6}} /usr/lib
ln -sv bash /bin/sh

ln -sv /proc/self/mounts /etc/mtab

cat > /etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/bin/false
daemon:x:6:6:Daemon User:/dev/null:/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/var/run/dbus:/bin/false
nobody:x:99:99:Unprivileged User:/dev/null:/bin/false
EOF
cat > /etc/group << "EOF"
root:x:0:
bin:x:1:daemon
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
adm:x:16:
messagebus:x:18:
systemd-journal:x:23:
input:x:24:
mail:x:34:
nogroup:x:99:
users:x:999:
EOF
exec /tools/bin/bash --login +h


#***********************************************************************************************
#>> LINUX HEADERS <<

tar -xf linux-4.18.1.tar.xz
cd linux-4.18.1

make mrproper
make ARCH=$CLFS_ARCH INSTALL_HDR_PATH=dest headers_install
find dest/include \( -name .install -o -name ..install.cmd \) -delete
cp -rv dest/include/* /usr/include

cd ..
rm -rf linux-4.18.1

#***********************************************************************************************
#>> GLIBC <<

tar -xf glibc-2.27.tar.xz
cd glibc-2.27

patch -Np1 -i ../glibc-2.27-fhs-1.patch
ln -sfv /ctools/lib/gcc /usr/lib

GCC_INCDIR=/usr/lib/gcc/arm-szilv-linux-gnueabihf/7.3.0/include
ln -sfv ld-linux-armhf.so.3 /lib/ld-lsb.so.3

rm -f /usr/include/limits.h
mkdir -v build
cd build


CC="$CLFS_TARGET-gcc -isystem $GCC_INCDIR -isystem /usr/include" \
../configure --prefix=/usr \
 --host=$CLFS_TARGET \
 --target=$CLFS_TARGET \
 --disable-werror \
 --enable-kernel=3.2 \
 --enable-stack-protector=strong \
 libc_cv_slibdir=/lib
unset GCC_INCDIR

make -j3
make install

touch /etc/ld.so.conf
cp -v ../nscd/nscd.conf /etc/nscd.conf
mkdir -pv /var/cache/nscd

cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib
EOF
cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf
EOF
mkdir -pv /etc/ld.so.conf.d


#mv -v /ctools/bin/{ld,ld-old}
#mv -v /ctools/bin/{$CLFS_TARGET-ld,$CLFS_TARGET-ld-old}
#mv -v /ctools/$CLFS_TARGET/bin/{ld,ld-old}
#mv -v /ctools/$CLFS_TARGET/bin/{ld,ld-old}
#mv -v /ctools/bin/{ld-new,ld}
#mv -v /ctools/bin/{$CLFS_TARGET-ld-new,$CLFS_TARGET-ld}
#ln -sv /ctools/bin/ld /ctools/$CLFS_TARGET/bin/ld
#ln -sv /ctools/bin/$CLFS_TARGET-ld /ctools/$CLFS_TARGET/bin/ld

#$CLFS_TARGET-gcc -dumpspecs | sed -e 's@/ctools@@g' \
# -e '/\*startfile_prefix_spec:/{n;s@.*@/usr/lib/ @}' \
# -e '/\*cpp:/{n;s@$@ -isystem /usr/include@}' > \
# `dirname $($CLFS_TARGET-gcc --print-libgcc-file-name)`/specs

#$CLFS_TARGET-cc dummy.c -v -Wl,--verbose &> dummy.log
#readelf -l a.out

cd ../..
rm -rf glibc-2.27

# !!!! TO RETURN !!!!



#***********************************************************************************************
#>> ZLIB <<

tar -xf zlib-1.2.11.tar.xz
cd zlib-1.2.11

CHOST=${CLFS_TARGET} ./configure --prefix=/usr
make -j3
make install

mv -v /usr/lib/libz.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libz.so) /usr/lib/libz.so

cd ..
rm -rf zlib-1.2.11


#***********************************************************************************************
#>> FILE <<

tar -xf file-5.32.tar.gz
cd file-5.32

./configure --prefix=/usr --host=$CLFS_TARGET
make -j3
make install

cd ..
rm -rf file-5.32


#***********************************************************************************************
#>> Readline <<

tar -xf readline-7.0.tar.gz
cd readline-7.0

./configure --prefix=/usr  --disable-static  --docdir=/usr/share/doc/readline-7.0 --host=$CLFS_TARGET
make -j3
make install

mv -v /usr/lib/lib{readline,history}.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libreadline.so) /usr/lib/libreadline.so
ln -sfv ../../lib/$(readlink /usr/lib/libhistory.so ) /usr/lib/libhistory.so

cd ..
rm -rf readline-7.0


#***********************************************************************************************
#>> M4 <<

tar -xf m4-1.4.18.tar.xz
cd m4-1.4.18

./configure --prefix=/usr --host=$CLFS_TARGET
make -j3
make install

cd ..
rm -rf m4-1.4.18

#***********************************************************************************************
#>> Binutils <<

tar -xf binutils-2.30.tar.xz
cd binutils-2.30

mkdir -v build
cd build
../configure \
 --prefix=/usr \
 --enable-gold \
 --enable-ld=default \
 --enable-plugins \
 --enable-shared \
 --disable-werror \
 --enable-64-bit-bfd \
 --with-system-zlib \
 --host=$CLFS_TARGET \
 --target=$CLFS_TARGET
make -j3 tooldir=/usr
make tooldir=/usr install

cd ../..
rm -rf binutils-2.30

#***********************************************************************************************
#>> GMP <<

tar -xf gmp-6.1.2.tar.xz
cd gmp-6.1.2

./configure --prefix=/usr \
 --enable-cxx \
 --disable-static \
 --docdir=/usr/share/doc/gmp-6.1.2 \
 --host=$CLFS_TARGET
make -j3
make install

cd ..
rm -rf gmp-6.1.2



#***********************************************************************************************
#>> MPFR <<

tar -xf mpfr-4.0.1.tar.xz
cd mpfr-4.0.1

./configure --prefix=/usr \
 --disable-static \
 --enable-thread-safe \
 --docdir=/usr/share/doc/mpfr-4.0.1 \
 --host=$CLFS_TARGET
make -j3
make install

cd ..
rm -rf mpfr-4.0.1


#***********************************************************************************************
#>> MPC <<

tar -xf mpc-1.1.0.tar.gz
cd mpc-1.1.0

./configure --prefix=/usr \
 --disable-static \
 --docdir=/usr/share/doc/mpc-1.1.0 \
 --host=$CLFS_TARGET
make -j3
make install

cd ..
rm -rf mpc-1.1.0


#***********************************************************************************************
#>> GCC <<

tar -xf gcc-7.3.0.tar.xz
cd gcc-7.3.0

rm -f /usr/lib/gcc
mkdir -v build
cd build
SED=sed \
../configure --prefix=/usr \
 --enable-languages=c,c++ \
 --disable-multilib \
 --disable-bootstrap \
 --with-system-zlib \
 --host=$CLFS_TARGET \
 --build=$CLFS_HOST \
 --target=$CLFS_TARGET \
 --with-arch=${CLFS_ARM_ARCH} \
 --with-float=${CLFS_FLOAT} \
 --with-fpu=${CLFS_FPU}
make -j3
make install

ln -sv ../usr/bin/cpp /lib
ln -sv gcc /usr/bin/cc
install -v -dm755 /usr/lib/bfd-plugins
ln -sfv ../../libexec/gcc/arm-szilv-linux-gnueabihf/7.3.0/liblto_plugin.so \
 /usr/lib/bfd-plugins/
mkdir -pv /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib

cd ../..
rm -rf gcc-7.3.0


#***********************************************************************************************
#>> Bzip <<

tar -xf bzip2-1.0.6.tar.gz
cd bzip2-1.0.6

patch -Np1 -i ../bzip2-1.0.6-install_docs-1.patch
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile

make -f Makefile-libbz2_so CC="${CC}" AR="${AR}" RANLIB="${RANLIB}"
make clean
make -j3 CC="${CC}" AR="${AR}" RANLIB="${RANLIB}"
make PREFIX=/usr install
cp -v bzip2-shared /bin/bzip2
cp -av libbz2.so* /lib
ln -sv ../../lib/libbz2.so.1.0 /usr/lib/libbz2.so
rm -v /usr/bin/{bunzip2,bzcat,bzip2}
ln -sv bzip2 /bin/bunzip2
ln -sv bzip2 /bin/bzcat

cd ..
rm -rf bzip2-1.0.6





   

#***********************************************************************************************
#>> pkg-config <<

tar -xf pkg-config-0.29.2.tar.gz
cd pkg-config-0.29.2

echo ac_cv_type_long_long=yes>$CLFS_TARGET.cache
echo glib_cv_stack_grows=no>>$CLFS_TARGET.cache
echo glib_cv_uscore=no>>$CLFS_TARGET.cache
echo ac_cv_func_posix_getpwuid_r=yes>>$CLFS_TARGET.cache
echo ac_cv_func_posix_getgrgid_r=yes>>$CLFS_TARGET.cache

./configure --prefix=/usr \
 --with-internal-glib \
 --disable-host-tool \
 --docdir=/usr/share/doc/pkg-config-0.29.2 \
 --host=$CLFS_TARGET \
 --target=$CLFS_TARGET \
 --cache-file=$CLFS_TARGET.cache
make -j3
make install

cd ..
rm -rf pkg-config-0.29.2



#***********************************************************************************************
#>> Ncurses <<

tar -xf ncurses-6.1.tar.gz
cd ncurses-6.1

sed -i '/LIBTOOL_INSTALL/d' c++/Makefile.in

./configure --prefix=/usr \
 --build=$CLFS_HOST \
 --host=$CLFS_TARGET \
 --with-shared \
 --without-debug \
 --without-normal \
 --with-build-cc=gcc \
 --enable-pc-files \
 --enable-widec \
 --disable-stripping

make -j3
make install

mv -v /usr/lib/libncursesw.so.6* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libncursesw.so) /usr/lib/libncursesw.so
for lib in ncurses form panel menu ; do
 rm -vf /usr/lib/lib${lib}.so
 echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
 ln -sfv ${lib}w.pc /usr/lib/pkgconfig/${lib}.pc
done
rm -vf /usr/lib/libcursesw.so
echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so
ln -sfv libncurses.so /usr/lib/libcurses.so

cd ..
rm -rf ncurses-6.1



#***********************************************************************************************
#>> Attr <<


tar -xf attr-2.4.47.src.tar.gz
cd attr-2.4.47

sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in
sed -i -e "/SUBDIRS/s|man[25]||g" man/Makefile
sed -i 's:{(:\\{(:' test/run

./configure --prefix=/usr \
 --bindir=/bin \
 --host=$CLFS_TARGET \
 --target=$CLFS_TARGET \
 --disable-static

make -j3
make install install-dev install-lib
chmod -v 755 /usr/lib/libattr.so
mv -v /usr/lib/libattr.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libattr.so) /usr/lib/libattr.so

cd ..
rm -rf attr-2.4.47



#***********************************************************************************************
#>> Acl <<


tar -xf acl-2.2.52.src.tar.gz
cd acl-2.2.52

sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in
sed -i "s:| sed.*::g" test/{sbits-restore,cp,misc}.test
sed -i 's/{(/\\{(/' test/run
sed -i -e "/TABS-1;/a if (x > (TABS-1)) x = (TABS-1);" \
 libacl/__acl_to_any_text.c

./configure --prefix=/usr \
 --host=$CLFS_TARGET \
 --target=$CLFS_TARGET \
 --bindir=/bin \
 --disable-static \
 --libexecdir=/usr/lib

make -j3
make install install-dev install-lib
chmod -v 755 /usr/lib/libacl.so
mv -v /usr/lib/libacl.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libacl.so) /usr/lib/libacl.so

cd ..
rm -rf acl-2.2.52


#***********************************************************************************************
#>> SED <<

tar -xf sed-4.4.tar.xz
cd sed-4.4

sed -i 's/usr/tools/' build-aux/help2man
sed -i 's/testsuite.panic-tests.sh//' Makefile.in

./configure --prefix=/usr --bindir=/bin \
 --host=$CLFS_TARGET \
 --target=$CLFS_TARGET

make -j3
make install

cd ..
rm -rf sed-4.4


#***********************************************************************************************
#>> Shadow <<

tar -xf shadow-4.5.tar.xz
cd shadow-4.5


sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 / /' {} \;
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /' {} \;

sed -i -e 's@#ENCRYPT_METHOD DES@ENCRYPT_METHOD SHA512@' \
 -e 's@/var/spool/mail@/var/mail@' etc/login.defs

sed -i 's/1000/999/' etc/useradd

./configure --sysconfdir=/etc --with-group-name-max-length=32 --host=$CLFS_TARGET
make -j3
make install
mv -v /usr/bin/passwd /bin

cd ..
rm -rf shadow-4.5

## TO RETURN ##



#***********************************************************************************************
#>> Bison <<

tar -xf bison-3.0.4.tar.xz
cd bison-3.0.4 

./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.0.4 --host=$CLFS_TARGET --target=$CLFS_TARGET
make -j3
make install

cd ..
rm -rf bison-3.0.4




#***********************************************************************************************
#>> Flex <<


tar -xf flex-2.6.4.tar.gz
cd flex-2.6.4

sed -i "/math.h/a #include <malloc.h>" src/flexdef.h
HELP2MAN=/tools/bin/true \
./configure --prefix=/usr --docdir=/usr/share/doc/flex-2.6.4 --host=$CLFS_TARGET --target=$CLFS_TARGET
make -j3
make install

ln -sv flex /usr/bin/lex

cd ..
rm -rf flex-2.6.4





#***********************************************************************************************
#>> Grep <<

tar -xf grep-3.1.tar.xz
cd grep-3.1	

./configure --prefix=/usr --bindir=/bin --host=$CLFS_TARGET --target=$CLFS_TARGET
make -j3
make install

cd ..
rm -rf grep-3.1





#***********************************************************************************************
#>> Bash <<


tar -xf bash-4.4.18.tar.gz
cd bash-4.4.18

./configure --prefix=/usr \
 --docdir=/usr/share/doc/bash-4.4.18 \
 --without-bash-malloc \
 --host=$CLFS_TARGET --target=$CLFS_TARGET \
 --with-installed-readline

make -j3
make install

mv -vf /usr/bin/bash /bin

cd ..
rm -rf bash-4.4.18


# !!! reset the sh link mv /bin/sh_bak /bin/sh


#***********************************************************************************************
#>> Gperf <<

tar -xf gperf-3.1.tar.gz
cd gperf-3.1

./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1 --host=$CLFS_TARGET --target=$CLFS_TARGET

make -j3
make install

cd ..
rm -rf gperf-3.1




#***********************************************************************************************
#>> Expat <<


tar -xf expat-2.2.5.tar.bz2
cd expat-2.2.5

sed -i 's|usr/bin/env |bin/|' run.sh.in

./configure --prefix=/usr --disable-static --host=$CLFS_TARGET --target=$CLFS_TARGET

make -j3
make install

cd ..
rm -rf expat-2.2.5


#***********************************************************************************************
#>> Autoconf <<


tar -xf autoconf-2.69.tar.xz
cd autoconf-2.69

./configure --prefix=/usr --host=$CLFS_TARGET --target=$CLFS_TARGET


make -j3
make install

cd ..
rm -rf autoconf-2.69




#***********************************************************************************************
#>> Automake <<

tar -xf automake-1.15.1.tar.xz
cd automake-1.15.1


./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.15.1 --host=$CLFS_TARGET --target=$CLFS_TARGET

make -j3
make install

cd ..
rm -rf automake-1.15.1




#***********************************************************************************************
#>> Xz <<

tar -xf xz-5.2.3.tar.xz
cd xz-5.2.3

./configure --prefix=/usr \
 --host=$CLFS_TARGET --target=$CLFS_TARGET \
 --disable-static \
 --docdir=/usr/share/doc/xz-5.2.3

make -j3
make install
mv -v /usr/bin/{lzma,unlzma,lzcat,xz,unxz,xzcat} /bin
mv -v /usr/lib/liblzma.so.* /lib
ln -svf ../../lib/$(readlink /usr/lib/liblzma.so) /usr/lib/liblzma.so

cd ..
rm -rf xz-5.2.3


#***********************************************************************************************
#>> Gettext <<
 
tar -xf gettext-0.19.8.1.tar.xz
cd gettext-0.19.8.1

./configure --prefix=/usr \
 --host=$CLFS_TARGET --target=$CLFS_TARGET \
 --disable-static \
 --docdir=/usr/share/doc/gettext-0.19.8.1

make -j3
make install
chmod -v 0755 /usr/lib/preloadable_libintl.so

cd ..
rm -rf gettext-0.19.9.1



#***********************************************************************************************
#>> Libffi <<

tar -xf libffi-3.2.1.tar.gz
cd libffi-3.2.1

sed -e '/^includesdir/ s/$(libdir).*$/$(includedir)/' \
 -i include/Makefile.in
sed -e '/^includedir/ s/=.*$/=@includedir@/' \
 -e 's/^Cflags: -I${includedir}/Cflags:/' \
 -i libffi.pc.in

./configure --prefix=/usr --disable-static --host=$CLFS_TARGET
make -j3
make install

cd ..
rm -rf libffi-3.2.1



#***********************************************************************************************
#>> Coreutils <<


tar -xf coreutils-8.29.tar.xz
cd coreutils-8.29

patch -Np1 -i ../coreutils-8.29-i18n-1.patch

FORCE_UNSAFE_CONFIGURE=1 ./configure \
 --host=$CLFS_TARGET --target=$CLFS_TARGET \
 --prefix=/usr \
 --enable-no-install-program=kill,uptime

FORCE_UNSAFE_CONFIGURE=1 make -j3
make install

mv -v /usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} /bin
mv -v /usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm} /bin
mv -v /usr/bin/{rmdir,stty,sync,true,uname} /bin
mv -v /usr/bin/chroot /usr/sbin
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
sed -i s/\"1\"/\"8\"/1 /usr/share/man/man8/chroot.8
mv -v /usr/bin/{head,sleep,nice} /bin

cd ..
rm -rf coreutils-8.29





#***********************************************************************************************
#>> Check <<

tar -xf check-0.12.0.tar.gz
cd check-0.12.0

./configure --prefix=/usr --host=$CLFS_TARGET --target=$CLFS_TARGET
make -j3
make install

cd ..
rm -rf check-0.12.0





#***********************************************************************************************
#>> Diffutils <<

tar -xf diffutils-3.6.tar.xz
cd diffutils-3.6

./configure --prefix=/usr --host=$CLFS_TARGET --build=$CLFS_HOST gl_cv_func_getopt_gnu=yes

make -j3 
make install

cd ..
rm -rf diffutils-3.6






#***********************************************************************************************
#>> Gawk <<

tar -xf gawk-4.2.0.tar.xz
cd gawk-4.2.0

sed -i 's/extras//' Makefile.in

./configure --prefix=/usr --host=$CLFS_TARGET --target=$CLFS_TARGET

make -j3
make install

cd ..
rm -rf gawk-4.2.0





#***********************************************************************************************
#>> Findutils <<

tar -xf findutils-4.6.0.tar.gz
cd findutils-4.6.0

./configure --prefix=/usr --localstatedir=/var/lib/locate --host=$CLFS_TARGET --build=$CLFS_HOST 

make -j3
make install

mv -v /usr/bin/find /bin
sed -i 's|find:=${BINDIR}|find:=/bin|' /usr/bin/updatedb

cd ..
rm -rf findutils-4.6.0



#***********************************************************************************************
#>> Less <<

tar -xf less-530.tar.gz
cd less-530

./configure --prefix=/usr --sysconfdir=/etc --host=$CLFS_TARGET --target=$CLFS_TARGET

make -j3
make install

cd ..
rm -rf less-530






#***********************************************************************************************
#>> Gzip <<

tar -xf gzip-1.9.tar.xz
cd gzip-1.9

./configure --prefix=/usr --host=$CLFS_TARGET --target=$CLFS_TARGET

make -j3
make install
mv -v /usr/bin/gzip /bin

cd ..
rm -rf gzip-1.9


#***********************************************************************************************
#>> Make << 

tar -xf make-4.2.1.tar.bz2
cd make-4.2.1

sed -i '211,217 d; 219,229 d; 232 d' glob/glob.c

./configure --prefix=/usr --host=$CLFS_TARGET --target=$CLFS_TARGET

make -j3
make install

cd ..
rm -rf make-4.2.1






#***********************************************************************************************
#>> Patch <<

tar -xf patch-2.7.6.tar.xz
cd patch-2.7.6

./configure --prefix=/usr --host=$CLFS_TARGET --target=$CLFS_TARGET

make -j3
make install

cd ..
rm -rf patch-2.7.6


#***********************************************************************************************
#>> Sysvinit <<

tar -xf sysvinit-2.88dsf.tar.bz2
cd sysvinit-2.88dsf

patch -Np1 -i ../sysvinit-2.88dsf-consolidated-1.patch

make -C src clobber
make -C src CC="${CC}"
make -C src install

cd ..
rm -rf sysvinit-2.88dsf