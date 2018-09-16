cat > ~/.bash_profile << "EOF"
export CORE_COUNT=1
EOF
source ~/.bash_profile


# don't forget to create the dev sys proc run folders on root partition
# this must be done on the machine where the SDCARD is mounted in
mkdir -pv /run/media/szilveszter/ROOT/{dev,proc,sys,run}


# and copy the remaining source files to SDCARD's root partiiton
# this must be done on the machine where the SDCARD is mounted in
mkdir /run/media/szilveszter/ROOT/sources
rsync -av root@192.168.1.199:/mnt/armv6_clfs/sources/{\
bash-4.4.18.tar.gz,\
tar-1.30.tar.xz,\
libcap-2.25.tar.xz,\
psmisc-23.1.tar.xz,\
iana-etc-2.30.tar.bz2,\
libtool-2.4.6.tar.xz,\
gdbm-1.14.1.tar.gz,\
inetutils-1.9.4.tar.xz,\
perl-5.26.1.tar.xz,\
XML-Parser-2.44.tar.gz,\
intltool-0.51.0.tar.gz,\
kmod-25.tar.xz,\
elfutils-0.170.tar.bz2,\
openssl-1.1.0g.tar.gz,\
Python-3.6.4.tar.xz,\
ninja-1.8.2.tar.gz,\
meson-0.44.0.tar.gz,\
procps-ng-3.3.12.tar.xz,\
dosfstools-4.1.tar.xz,\
e2fsprogs-1.43.9.tar.gz,\
groff-1.22.3.tar.gz,\
iproute2-4.15.0.tar.xz,\
kbd-2.0.4.tar.xz,\
libpipeline-1.5.0.tar.gz,\
sysklogd-1.5.1.tar.gz,\
eudev-3.2.5.tar.gz,\
man-db-2.8.1.tar.xz,\
texinfo-6.5.tar.xz,\
vim-8.0.586.tar.bz2\
} /run/media/szilveszter/ROOT/sources


# First of all, we have to recompile bash, I don't know why,
# but with the cross-compiled version some compilations silently fails
#***********************************************************************************************
#>> Bash <<  
tar -xf bash-4.4.18.tar.gz
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


# BC is not required unless you want to compile linux kernel on the final system
#***********************************************************************************************
#>> BC<<  
# tar -xf bc-1.07.1.tar.gz
# cd bc-1.07.1

# cat > bc/fix-libmath_h << "EOF"
# #! /bin/bash
# sed -e '1 s/^/{"/' \
#  -e 's/$/",/' \
#  -e '2,$ s/^/"/' \
#  -e '$ d' \
#  -i libmath.h
# sed -e '$ s/$/0}/' \
#  -i libmath.h
# EOF
# ln -sv /ctools/lib/libncursesw.so.6 /usr/lib/libncursesw.so.6
# ln -sfv libncurses.so.6 /usr/lib/libncurses.so
# sed -i -e '/flex/s/as_fn_error/: ;; # &/' configure

# ./configure --prefix=/usr \
#  --with-readline \
#  --mandir=/usr/share/man \
#  --infodir=/usr/share/info
# make -j$CORE_COUNT
# make install

# cd ..
# rm -rf bc-1.07.1





#***********************************************************************************************
#>>  Psmisc-23.1  << 
tar -xf psmisc-23.1.tar.xz
cd psmisc-23.1

./configure --prefix=/usr
make -j$CORE_COUNT
make install

mv -v /usr/bin/fuser /bin
mv -v /usr/bin/killall /bin

cd ..
rm -rf psmisc-23.1




#***********************************************************************************************
#>> Iana-Etc  << 
tar -xf iana-etc-2.30.tar.bz2
cd iana-etc-2.30

make -j$CORE_COUNT
make install

cd ..
rm -rf iana-etc-2.30



#***********************************************************************************************
#>> 6.35. Libtool-2.4.6 << 
tar -xf libtool-2.4.6.tar.xz
cd libtool-2.4.6

./configure --prefix=/usr

make -j$CORE_COUNT
make install

cd ..
rm -rf libtool-2.4.6




#***********************************************************************************************
#>> 6.36. GDBM-1.14.1 << 
tar -xf tar -xf gdbm-1.14.1.tar.gz
cd tar -xf gdbm-1.14.1

./configure --prefix=/usr \
 --disable-static \
 --enable-libgdbm-compat

make -j$CORE_COUNT
make install

cd ..
rm -rf gdbm-1.14.1




#***********************************************************************************************
#>> 6.39. Inetutils-1.9.4 << 
tar -xf inetutils-1.9.4.tar.xz
cd inetutils-1.9.4

./configure --prefix=/usr \
 --localstatedir=/var \
 --disable-logger \
 --disable-whois \
 --disable-rcp \
 --disable-rexec \
 --disable-rlogin \
 --disable-rsh \
 --disable-servers

make -j$CORE_COUNT
make install

mv -v /usr/bin/{hostname,ping,ping6,traceroute} /bin
mv -v /usr/bin/ifconfig /sbin

cd ..
rm -rf inetutils-1.9.4





#***********************************************************************************************
#>> 6.40. Perl-5.26.1 << 
tar -xf perl-5.26.1.tar.xz
cd perl-5.26.1

echo "127.0.0.1 localhost $(hostname)" > /etc/hosts

export BUILD_ZLIB=False
export BUILD_BZIP2=0

sh Configure -des -Dprefix=/usr \
 -Dvendorprefix=/usr \
 -Dman1dir=/usr/share/man/man1 \
 -Dman3dir=/usr/share/man/man3 \
 -Dpager="/usr/bin/less -isR" \
 -Duseshrplib \
 -Dusethreads

make -j$CORE_COUNT
make install

unset BUILD_ZLIB BUILD_BZIP2

cd ..
rm -rf perl-5.26.1




#***********************************************************************************************
#>> Libcap << 
tar -xf libcap-2.25.tar.xz
cd libcap-2.25

sed -i '/install.*STALIBNAME/d' libcap/Makefile

make -j$CORE_COUNT

make RAISE_SETFCAP=no lib=lib prefix=/usr install
chmod -v 755 /usr/lib/libcap.so

mv -v /usr/lib/libcap.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libcap.so) /usr/lib/libcap.so

cd ..
rm -rf libcap-2.25




#***********************************************************************************************
#>> 6.41. XML::Parser-2.44 << 
tar -xf XML-Parser-2.44.tar.gz
cd XML-Parser-2.44

perl Makefile.PL

make -j$CORE_COUNT
make install

cd ..
rm -rf XML-Parser-2.44



#***********************************************************************************************
#>> 6.42. Intltool-0.51.0 << 
tar -xf intltool-0.51.0.tar.gz
cd intltool-0.51.0

sed -i 's:\\\${:\\\$\\{:' intltool-update.in

./configure --prefix=/usr

make -j$CORE_COUNT
make install

install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO

cd ..
rm -rf intltool-0.51.0




#***********************************************************************************************
#>> 6.46. Kmod-25 << 
tar -xf kmod-25.tar.xz
cd kmod-25

./configure --prefix=/usr \
 --bindir=/bin \
 --sysconfdir=/etc \
 --with-rootlibdir=/lib \
 --with-xz \
 --with-zlib

make -j$CORE_COUNT
make install

for target in depmod insmod lsmod modinfo modprobe rmmod; do
 ln -sfv ../bin/kmod /sbin/$target
done
ln -sfv kmod /bin/lsmod

cd ..
rm -rf kmod-25




#***********************************************************************************************
#>> 6.48. Libelf 0.170 << 
tar -xf elfutils-0.170.tar.bz2
cd elfutils-0.170

./configure --prefix=/usr

make -j$CORE_COUNT
make -C libelf install

install -vm644 config/libelf.pc /usr/lib/pkgconfig

cd ..
rm -rf elfutils-0.170




#***********************************************************************************************
#>> 6.50. OpenSSL-1.1.0g << 
tar -xf openssl-1.1.0g.tar.gz
cd openssl-1.1.0g

./config --prefix=/usr \
 --openssldir=/etc/ssl \
 --libdir=lib \
 shared \
 zlib-dynamic

make -j$CORE_COUNT

sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make MANSUFFIX=ssl install

cd ..
rm -rf openssl-1.1.0g





#***********************************************************************************************
#>> 6.51. Python-3.6.4 << 
tar -xf Python-3.6.4.tar.xz
cd Python-3.6.4

./configure --prefix=/usr \
 --enable-shared \
 --with-system-expat \
 --with-system-ffi \
 --with-ensurepip=yes

make -j$CORE_COUNT
make install
chmod -v 755 /usr/lib/libpython3.6m.so
chmod -v 755 /usr/lib/libpython3.so

cd ..
rm -rf Python-3.6.4




#***********************************************************************************************
#>> 6.52. Ninja-1.8.2 << 
tar -xf ninja-1.8.2.tar.gz
cd ninja-1.8.2

python3 configure.py --bootstrap

install -vm755 ninja /usr/bin/
install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
install -vDm644 misc/zsh-completion /usr/share/zsh/site-functions/_ninja

cd ..
rm -rf ninja-1.8.2



#***********************************************************************************************
#>> 6.53. Meson-0.44.0 << 
tar -xf meson-0.44.0.tar.gz
cd meson-0.44.0

python3 setup.py build
python3 setup.py install

cd ..
rm -rf meson-0.44.0




#***********************************************************************************************
#>> 6.54. Procps-ng-3.3.12 << 
tar -xf procps-ng-3.3.12.tar.xz
cd procps-ng-3.3.12

./configure --prefix=/usr \
 --exec-prefix= \
 --libdir=/usr/lib \
 --docdir=/usr/share/doc/procps-ng-3.3.12 \
 --disable-static \
 --disable-kill

make -j$CORE_COUNT
make install

mv -v /usr/lib/libprocps.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libprocps.so) /usr/lib/libprocps.so

cd ..
rm -rf procps-ng-3.3.12




#***********************************************************************************************
#>> dosfstools-4.1 << 
tar -xf dosfstools-4.1.tar.xz
cd dosfstools-4.1

./configure --prefix=/               \
            --enable-compat-symlinks \
            --mandir=/usr/share/man  \
            --docdir=/usr/share/doc/dosfstools-4.1
make -j$CORE_COUNT
make install

cd ..
rm -rf dosfstools-4.1




#***********************************************************************************************
#>> 6.55. E2fsprogs-1.43.9 << 
tar -xf e2fsprogs-1.43.9.tar.gz
cd e2fsprogs-1.43.9

mkdir -v build
cd build

LIBS=-L/tools/lib \
CFLAGS=-I/tools/include \
PKG_CONFIG_PATH=/tools/lib/pkgconfig \
../configure --prefix=/usr \
 --bindir=/bin \
 --with-root-prefix="" \
 --enable-elf-shlibs \
 --disable-libblkid \
 --disable-libuuid \
 --disable-uuidd \
 --disable-fsck

make -j$CORE_COUNT
make install
make install-libs

chmod -v u+w /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a

gunzip -v /usr/share/info/libext2fs.info.gz
install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info

cd ../..
rm -rf e2fsprogs-1.43.9



#***********************************************************************************************
#>> 6.61. Groff-1.22.3 << 
tar -xf groff-1.22.3.tar.gz
cd groff-1.22.3

PAGE=A4 ./configure --prefix=/usr

make -j1
make install

cd ..
rm -rf groff-1.22.3




#***********************************************************************************************
#>> 6.65. IPRoute2-4.15.0 << 
tar -xf iproute2-4.15.0.tar.xz
cd iproute2-4.15.0

sed -i /ARPD/d Makefile
rm -fv man/man8/arpd.8

sed -i 's/m_ipt.o//' tc/Makefile

make -j$CORE_COUNT
make DOCDIR=/usr/share/doc/iproute2-4.15.0 install

cd ..
rm -rf iproute2-4.15.0




#***********************************************************************************************
#>> 6.66. Kbd-2.0.4 << 
tar -xf kbd-2.0.4.tar.xz
cd kbd-2.0.4

patch -Np1 -i ../kbd-2.0.4-backspace-1.patch

sed -i 's/\(RESIZECONS_PROGS=\)yes/\1no/g' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in

PKG_CONFIG_PATH=/tools/lib/pkgconfig ./configure --prefix=/usr --disable-vlock

make -j$CORE_COUNT
make install

cd ..
rm -rf kbd-2.0.4



#***********************************************************************************************
#>> 6.67. Libpipeline-1.5.0 << 
tar -xf libpipeline-1.5.0.tar.gz
cd libpipeline-1.5.0

./configure --prefix=/usr
make -j$CORE_COUNT
make install

cd ..
rm -rf libpipeline-1.5.0




#***********************************************************************************************
#>> 6.70. Sysklogd-1.5.1 << 
tar -xf sysklogd-1.5.1.tar.gz
cd sysklogd-1.5.1

sed -i '/Error loading kernel symbols/{n;n;d}' ksym_mod.c
sed -i 's/union wait/int/' syslogd.c

make -j$CORE_COUNT
make BINDIR=/sbin install

cat > /etc/syslog.conf << "EOF"
# Begin /etc/syslog.conf
auth,authpriv.* -/var/log/auth.log
*.*;auth,authpriv.none -/var/log/sys.log
daemon.* -/var/log/daemon.log
kern.* -/var/log/kern.log
mail.* -/var/log/mail.log
user.* -/var/log/user.log
*.emerg *
# End /etc/syslog.conf
EOF

cd ..
rm -rf sysklogd-1.5.1




#***********************************************************************************************
#>> 6.72. Eudev-3.2.5 << 
tar -xf eudev-3.2.5.tar.gz
cd eudev-3.2.5

cat > config.cache << "EOF"
HAVE_BLKID=1
BLKID_LIBS="-lblkid"
BLKID_CFLAGS="-I/ctools/include"
EOF

./configure --prefix=/usr \
 --bindir=/sbin \
 --sbindir=/sbin \
 --libdir=/usr/lib \
 --sysconfdir=/etc \
 --libexecdir=/lib \
 --with-rootprefix= \
 --with-rootlibdir=/lib \
 --enable-manpages \
 --disable-static \
 --config-cache

LIBRARY_PATH=/tools/lib make -j$CORE_COUNT

mkdir -pv /lib/udev/rules.d
mkdir -pv /etc/udev/rules.d

make LD_LIBRARY_PATH=/tools/lib install

tar -xvf ../udev-lfs-20171102.tar.bz2
make -f udev-lfs-20171102/Makefile.lfs install

LD_LIBRARY_PATH=/tools/lib udevadm hwdb --update

cd ..
rm -rf eudev-3.2.5




#***********************************************************************************************
#>> 6.74. Man-DB-2.8.1 << 
tar -xf man-db-2.8.1.tar.xz
cd man-db-2.8.1

./configure --prefix=/usr \
 --docdir=/usr/share/doc/man-db-2.8.1 \
 --sysconfdir=/etc \
 --disable-setuid \
 --enable-cache-owner=bin \
 --with-browser=/usr/bin/lynx \
 --with-vgrind=/usr/bin/vgrind \
 --with-grap=/usr/bin/grap \
 --with-systemdtmpfilesdir=

make -j$CORE_COUNT
make install

cd ..
rm -rf man-db-2.8.1




#***********************************************************************************************
#>> 6.76. Texinfo-6.5 << 
tar -xf texinfo-6.5.tar.xz
cd texinfo-6.5

./configure --prefix=/usr --disable-static

make -j$CORE_COUNT
make install

make TEXMF=/usr/share/texmf install-texs

cd ..
rm -rf texinfo-6.5




#***********************************************************************************************
#>> 6.77. Vim-8.0.586 << 
tar -xf vim-8.0.586.tar.bz2
cd vim80

echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h

./configure --prefix=/usr

make -j$CORE_COUNT
make install

ln -sv vim /usr/bin/vi
for L in /usr/share/man/{,*/}man1/vim.1; do
 ln -sv vim.1 $(dirname $L)/vi.1
done

ln -sv ../vim/vim80/doc /usr/share/doc/vim-8.0.586

cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc
" Ensure defaults are set before customizing settings, not after
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim=1
set nocompatible
set backspace=2
set mouse=
syntax on
if (&term == "xterm") || (&term == "putty")
 set background=dark
endif
" End /etc/vimrc
EOF

cd ..
rm -rf vim80

