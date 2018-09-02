# it is not neccessary if we are already logged in with lfs user
mkdir -v $LFS/ctools
unlink /ctools
ln -sv $LFS/ctools /

chown -v lfs $LFS/tools
chown -v lfs $LFS/sources
chown -v lfs $LFS/ctools
su - lfs


cat > ~/.bashrc << "EOF"
set +h
umask 022
CLFS_DIR=armv6_clfs
LFS=/mnt/$CLFS_DIR
CORE_COUNT=3
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/tools/bin:/ctools/bin:/bin:/usr/bin
export LFS LC_ALL LFS_TGT PATH CORE_COUNT

export CLFS_HOST="i686-cross-linux-gnu"
export CLFS_TARGET="arm-szilv-linux-gnueabihf"
export CLFS_ARCH="arm"
export CLFS_ARM_ARCH="armv6z"
export CLFS_FLOAT="hard"
export CLFS_FPU="vfpv2"
EOF
source ~/.bashrc
source ~/.bash_profile



# Build cross toolchain in the previously built temporary system
cd $LFS/sources
#***********************************************************************************************
#>> BINUTILS <<

tar -xf binutils-2.31.tar.xz
cd binutils-2.31

mkdir -v build
cd build
../configure \
 --prefix=/ctools \
 --target=$CLFS_TARGET \
 --with-sysroot=/ctools/$CLFS_TARGET \
 --disable-nls \
 --disable-werror
make -j$CORE_COUNT
make install

cd ../..
rm -rf binutils-2.31


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
 --prefix=/ctools \
 --with-glibc-version=2.11 \
 --build=$CLFS_HOST \
 --host=$CLFS_HOST \
 --target=$CLFS_TARGET \
 --with-sysroot=/ \
 --with-newlib \
 --without-headers \
 --with-local-prefix=/ctools/$CLFS_TARGET \
 --with-native-system-header-dir=/ctools/$CLFS_TARGET/include \
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
#>> LINUX HEADERS <<
tar -xf linux-4.18.1.tar.xz
cd linux-4.18.1

make mrproper
make ARCH=$CLFS_ARCH headers_check
make ARCH=$CLFS_ARCH INSTALL_HDR_PATH=/ctools/$CLFS_TARGET headers_install

cd ..
rm -rf linux-4.18.1



#***********************************************************************************************
#>> GLIBC <<

tar -xf glibc-2.27.tar.xz
cd glibc-2.27

mkdir -v build
cd build
../configure \
 --prefix=/ctools/$CLFS_TARGET \
 --host=$CLFS_TARGET \
 --target=$CLFS_TARGET \
 --build=$(../scripts/config.guess) \
 --enable-kernel=3.2 \
 --with-headers=/ctools/$CLFS_TARGET/include \
 libc_cv_forced_unwind=yes \
 libc_cv_c_cleanup=yes
make -j$CORE_COUNT
make install

cd ../..
rm -rf glibc-2.27




#***********************************************************************************************
#>> LIBSTDC++ <<

tar -xf gcc-8.2.0.tar.xz
cd gcc-8.2.0

mkdir -v build
cd build
../libstdc++-v3/configure \
 --prefix=/ctools/$CLFS_TARGET \
 --build=${CLFS_HOST} \
 --host=${CLFS_TARGET} \
 --target=${CLFS_TARGET} \
 --disable-multilib \
 --disable-nls \
 --disable-libstdcxx-threads \
 --disable-libstdcxx-pch \
 --with-gxx-include-dir=/ctools/$CLFS_TARGET/include/c++/8.2.0
make -j$CORE_COUNT
make install

cd ../..
rm -rf gcc-8.2.0





#***********************************************************************************************
#>> BINUTILS pass2 <<

tar -xf binutils-2.31.tar.xz
cd binutils-2.31

mkdir -v build
cd build
../configure \
 --target=$CLFS_TARGET \
 --prefix=/ctools \
 --disable-nls \
 --disable-werror \
 --with-sysroot
make -j$CORE_COUNT
make install

make -C ld clean
make -C ld LIB_PATH=/usr/lib:/lib:/ctools/$CLFS_TARGET/lib
cp -v ld/ld-new /ctools/bin/$CLFS_TARGET-ld-new

cd ../..
rm -rf binutils-2.31




#***********************************************************************************************
#>> GCC pass2<<

tar -xf gcc-8.2.0.tar.xz
cd gcc-8.2.0

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
rm -rf gcc-8.2.0