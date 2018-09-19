## put this into the user's bash_profile
export CLFS_DIR=armv7_clfs
## Settings the $LFS variable
export LFS=/mnt/$CLFS_DIR 

source ~/.bash_profile

# sources directory
mkdir -v $LFS
mkdir -v $LFS/sources
chmod -v a+wt $LFS/sources

#download and check the neccessary packages
wget --input-file=wget-list --continue --directory-prefix=$LFS/sources
pushd $LFS/sources
md5sum -c md5sums
popd


# create lfs user
groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs

passwd lfs
chown -v lfs $LFS
su - lfs

cat > ~/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

cat > ~/.bashrc << "EOF"
set +h
umask 022
CLFS_DIR=armv7_clfs
LFS=/mnt/$CLFS_DIR
CORE_COUNT=3
LC_ALL=POSIX
PATH=${LFS}/ctools/bin:/bin:/usr/bin
export LFS LC_ALL PATH CORE_COUNT
unset CFLAGS
unset CXXFLAGS

export CLFS_HOST="i686-cross-linux-gnu"
export CLFS_TARGET="armv7-szilv-linux-gnueabihf"
export CLFS_ARCH="arm"
export CLFS_ARM_ARCH="armv7-a"
export CLFS_FLOAT="hard"
export CLFS_FPU="vfpv3-d16"
EOF

source ~/.bash_profile
source ~/.bashrc

mkdir -p ${LFS}/ctools/${CLFS_TARGET}
ln -sfv . ${LFS}/ctools/${CLFS_TARGET}/usr



cd $LFS/sources
#***********************************************************************************************
#>> LINUX HEADERS <<
tar -xf linux-4.18.8.tar.xz
cd linux-4.18.8

make mrproper
make ARCH=$CLFS_ARCH headers_check
make ARCH=$CLFS_ARCH INSTALL_HDR_PATH=$LFS/ctools/$CLFS_TARGET headers_install

cd ..
rm -rf linux-4.18.8



#***********************************************************************************************
#>> BINUTILS <<
tar -xf binutils-2.31.1.tar.xz
cd binutils-2.31.1

mkdir -v build
cd build
../configure \
 --prefix=$LFS/ctools \
 --target=$CLFS_TARGET \
 --with-sysroot=$LFS/ctools/$CLFS_TARGET \
 --disable-nls \
 --disable-werror
make -j$CORE_COUNT
make install

cd ../..
rm -rf binutils-2.31.1


#***********************************************************************************************
#>> GCC <<

tar -xf gcc-8.2.0.tar.xz
cd gcc-8.2.0

tar -xf ../mpfr-4.0.1.tar.xz
mv -v mpfr-4.0.1 mpfr
tar -xf ../gmp-6.1.2.tar.xz
mv -v gmp-6.1.2 gmp
tar -xf ../mpc-1.1.0.tar.gz
mv -v mpc-1.1.0 mpc

mkdir -v build
cd build

../configure \
 --prefix=$LFS/ctools \
 --with-glibc-version=2.11 \
 --build=$CLFS_HOST \
 --host=$CLFS_HOST \
 --target=$CLFS_TARGET \
 --with-sysroot=/ \
 --with-local-prefix=$LFS/ctools/$CLFS_TARGET \
 --with-native-system-header-dir=$LFS/ctools/$CLFS_TARGET/include \
 --with-newlib \
 --without-headers \
 --disable-nls \
 --disable-shared \
 --disable-multilib \
 --disable-decimal-float \
 --disable-threads \
 --disable-libatomic \
 --disable-libgomp \
 --disable-libmpx \
 --disable-libquadmath \
 --disable-libssp \
 --disable-libvtv \
 --disable-libstdcxx \
 --enable-languages=c,c++ \
 --with-arch=${CLFS_ARM_ARCH} \
 --with-float=${CLFS_FLOAT} \
 --with-fpu=${CLFS_FPU}

make -j$CORE_COUNT
make install

cd ../..
rm -rf gcc-8.2.0




#***********************************************************************************************
#>> GLIBC <<
tar -xf glibc-2.28.tar.xz
cd glibc-2.28

mkdir -v build
cd build
../configure \
 --prefix=$LFS/ctools/$CLFS_TARGET \
 --host=$CLFS_TARGET \
 --target=$CLFS_TARGET \
 --build=$(../scripts/config.guess) \
 --enable-kernel=3.2 \
 --with-headers=$LFS/ctools/$CLFS_TARGET/include \
 libc_cv_forced_unwind=yes \
 libc_cv_c_cleanup=yes
make -j$CORE_COUNT
make install
#DESTDIR=$LFS/ctools/$CLFS_TARGET make install

cd ../..
rm -rf glibc-2.28



#***********************************************************************************************
#>> LIBSTDC++ <<
tar -xf gcc-8.2.0.tar.xz
cd gcc-8.2.0

mkdir -v build
cd build
../libstdc++-v3/configure \
 --prefix=$LFS/ctools \
 --build=${CLFS_HOST} \
 --host=${CLFS_TARGET} \
 --target=${CLFS_TARGET} \
 --with-sysroot=/ \
 --with-local-prefix=$LFS/ctools/$CLFS_TARGET \
 --with-native-system-header-dir=$LFS/ctools/$CLFS_TARGET/include \
 --disable-multilib \
 --disable-nls \
 --disable-libstdcxx-threads \
 --disable-libstdcxx-pch \
 --with-gxx-include-dir=$LFS/ctools/$CLFS_TARGET/include/c++/8.2.0
make -j$CORE_COUNT
make install

cd ../..
rm -rf gcc-8.2.0



#***********************************************************************************************
#>> BINUTILS pass2 <<
tar -xf binutils-2.31.1.tar.xz
cd binutils-2.31.1

mkdir -v build
cd build
../configure \
 --target=$CLFS_TARGET \
 --prefix=$LFS/ctools \
 --disable-nls \
 --disable-werror \
 --with-sysroot
make -j$CORE_COUNT
make install

make -C ld clean
make -C ld LIB_PATH=/usr/lib:/lib:$LFS/ctools/$CLFS_TARGET/lib
cp -v ld/ld-new $LFS/ctools/bin/$CLFS_TARGET-ld-new

cd ../..
rm -rf binutils-2.31.1





#***********************************************************************************************
#>> GCC pass2<<

tar -xf gcc-7.3.0.tar.xz
cd gcc-7.3.0

cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
 `dirname $($CLFS_TARGET-gcc -print-libgcc-file-name)`/include-fixed/limits.h



tar -xf ../mpfr-4.0.1.tar.xz
mv -v mpfr-4.0.1 mpfr
tar -xf ../gmp-6.1.2.tar.xz
mv -v gmp-6.1.2 gmp
tar -xf ../mpc-1.1.0.tar.gz
mv -v mpc-1.1.0 mpc

mkdir -v build
cd build

../configure \
 --prefix=/ctools \
 --with-sysroot=/ \
 --build=$CLFS_HOST \
 --host=$CLFS_HOST \
 --target=$CLFS_TARGET \
 --with-local-prefix=/ctools/$CLFS_TARGET \
 --with-native-system-header-dir=/ctools/$CLFS_TARGET/include \
 --enable-languages=c,c++ \
 --disable-libstdcxx-pch \
 --disable-multilib \
 --disable-bootstrap \
 --disable-libgomp \
 --with-arch=${CLFS_ARM_ARCH} \
 --with-float=${CLFS_FLOAT} \
 --with-fpu=${CLFS_FPU}
make -j$CORE_COUNT
make install
ln -sv $CLFS_TARGET-gcc /ctools/bin/$CLFS_TARGET-cc

cd ../..
rm -rf gcc-7.3.0



mkdir -pv $LFS/{dev,proc,sys,run}
mkdir -pv $LFS/{bin,boot,etc/{opt,sysconfig},home,lib/firmware,mnt,opt}
mkdir -pv $LFS/{media/{floppy,cdrom},sbin,srv,var}
install -dv -m 0750 $LFS/root
install -dv -m 1777 $LFS/tmp $LFS/var/tmp
mkdir -pv $LFS/usr/{,local/}{bin,include,lib,sbin,src}
mkdir -pv $LFS/usr/{,local/}share/{color,dict,doc,info,locale,man}
mkdir -v $LFS/usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -v $LFS/usr/libexec
mkdir -pv $LFS/usr/{,local/}share/man/man{1..8}
mkdir -v $LFS/var/{log,mail,spool}
ln -sv $LFS/run $LFS/var/run
ln -sv $LFS/run/lock $LFS/var/lock
mkdir -pv $LFS/var/{opt,cache,lib/{color,misc,locate},local}
