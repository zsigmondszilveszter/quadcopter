## put this into the user's bash_profile
export CLFS_DIR=armv6_clfs
## Settings the $LFS variable
export LFS=/mnt/$CLFS_DIR 

source ~/.bash_profile

# sources directory
mkdir -v $LFS/sources
chmod -v a+wt $LFS/sources

#download and check the neccessary packages
wget --input-file=wget-list --continue --directory-prefix=$LFS/sources
pushd $LFS/sources
md5sum -c md5sums
popd

# lfs tools directory
mkdir -v $LFS/tools
unlink /tools
ln -sv $LFS/tools /

# create lfs user
groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs

# password
passwd lfs

chown -vR lfs $LFS/tools
chown -v lfs $LFS/sources
su - lfs

cat > ~/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

cat > ~/.bashrc << "EOF"
set +h
umask 022
CLFS_DIR=armv6_clfs
LFS=/mnt/$CLFS_DIR
CORE_COUNT=3
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/tools/bin:/bin:/usr/bin
export LFS LC_ALL LFS_TGT PATH CORE_COUNT
EOF

source ~/.bash_profile


cd  $LFS/sources
#***********************************************************************************************
#5.4. Binutils-2.31.1 - Pass 1
tar -xf binutils-2.31.tar.xz
cd binutils-2.31/

mkdir -v build
cd build

../configure --prefix=/tools \
 --with-sysroot=$LFS \
 --with-lib-path=/tools/lib \
 --target=$LFS_TGT \
 --disable-nls \
 --disable-werror

make -j$CORE_COUNT
make install

cd ../..
rm -rf binutils-2.31/


#***********************************************************************************************
#5.5. GCC-8.2.0 - Pass 1
tar -xf gcc-7.3.0.tar.xz
cd gcc-7.3.0

tar -xf ../mpfr-4.0.1.tar.xz
mv -v mpfr-4.0.1 mpfr
tar -xf ../gmp-6.1.2.tar.xz
mv -v gmp-6.1.2 gmp
tar -xf ../mpc-1.1.0.tar.gz
mv -v mpc-1.1.0 mpc

for file in gcc/config/{linux,i386/linux{,64}}.h
do
 cp -uv $file{,.orig}
 sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
 -e 's@/usr@/tools@g' $file.orig > $file
 echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
 touch $file.orig
done

mkdir -v build
cd build

../configure \
 --target=$LFS_TGT \
 --prefix=/tools \
 --with-glibc-version=2.11 \
 --with-sysroot=$LFS \
 --with-newlib \
 --without-headers \
 --with-local-prefix=/tools \
 --with-native-system-header-dir=/tools/include \
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
 --enable-languages=c,c++

make -j$CORE_COUNT
make install

cd ../..
rm -rf gcc-7.3.0


#***********************************************************************************************
# 5.6. Linux-4.15.3 API Headers
tar -xf linux-4.18.5.tar.xz
cd linux-4.18.5

make mrproper
make INSTALL_HDR_PATH=dest headers_install
cp -rv dest/include/* /tools/include

cd ..
rm -rf linux-4.18.5


#***********************************************************************************************
# 5.7. Glibc-2.27
tar -xf glibc-2.27.tar.xz
cd glibc-2.27

mkdir -v build
cd build

../configure \
 --prefix=/tools \
 --host=$LFS_TGT \
 --build=$(../scripts/config.guess) \
 --enable-kernel=3.2 \
 --with-headers=/tools/include \
 libc_cv_forced_unwind=yes \
 libc_cv_c_cleanup=yes

make -j$CORE_COUNT
make install

# optionally
echo 'int main(){}' > dummy.c
$LFS_TGT-gcc dummy.c
readelf -l a.out | grep ': /tools'
rm -v dummy.c a.out

cd ../..
rm -rf glibc-2.27


#***********************************************************************************************
# 5.8. Libstdc++-8.2.0
tar -xf gcc-7.3.0.tar.xz
cd gcc-7.3.0

mkdir -v build
cd build

../libstdc++-v3/configure \
 --host=$LFS_TGT \
 --prefix=/tools \
 --disable-multilib \
 --disable-nls \
 --disable-libstdcxx-threads \
 --disable-libstdcxx-pch \
 --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/7.3.0

make -j$CORE_COUNT
make install

cd ../..
rm -rf gcc-7.3.0


#***********************************************************************************************
# 5.9. Binutils-2.31.1 - Pass 2
tar -xf binutils-2.31.tar.xz
cd binutils-2.31/

mkdir -v build
cd build

CC=$LFS_TGT-gcc \
AR=$LFS_TGT-ar \
RANLIB=$LFS_TGT-ranlib \
../configure \
 --prefix=/tools \
 --disable-nls \
 --disable-werror \
 --with-lib-path=/tools/lib \
 --with-sysroot

make -j$CORE_COUNT
make install

make -C ld clean
make -C ld LIB_PATH=/usr/lib:/lib
cp -v ld/ld-new /tools/bin

cd ../..
rm -rf binutils-2.31


#***********************************************************************************************
# 5.10. GCC-8.2.0 - Pass 2
tar -xf gcc-7.3.0.tar.xz
cd gcc-7.3.0

cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
 `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include-fixed/limits.h

for file in gcc/config/{linux,i386/linux{,64}}.h
do
 cp -uv $file{,.orig}
 sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
 -e 's@/usr@/tools@g' $file.orig > $file
 echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
 touch $file.orig
done

tar -xf ../mpfr-4.0.1.tar.xz
mv -v mpfr-4.0.1 mpfr
tar -xf ../gmp-6.1.2.tar.xz
mv -v gmp-6.1.2 gmp
tar -xf ../mpc-1.1.0.tar.gz
mv -v mpc-1.1.0 mpc

mkdir -v build
cd build

CC=$LFS_TGT-gcc \
CXX=$LFS_TGT-g++ \
AR=$LFS_TGT-ar \
RANLIB=$LFS_TGT-ranlib \
../configure \
 --prefix=/tools \
 --with-local-prefix=/tools \
 --with-native-system-header-dir=/tools/include \
 --enable-languages=c,c++ \
 --disable-libstdcxx-pch \
 --disable-multilib \
 --disable-bootstrap \
 --disable-libgomp

make -j$CORE_COUNT
make install
ln -sv gcc /tools/bin/cc

# echo 'int main(){}' > dummy.c
# cc dummy.c
# readelf -l a.out | grep ': /tools'
rm -v dummy.c a.out

cd ../..
rm -rf gcc-7.3.0

#***********************************************************************************************
# 5.11. Tcl-core-8.6.8
tar -xf tcl8.6.8-src.tar.gz
cd tcl8.6.8

cd unix
./configure --prefix=/tools

make -j$CORE_COUNT
make install
chmod -v u+w /tools/lib/libtcl8.6.so
make install-private-headers
ln -sv tclsh8.6 /tools/bin/tclsh

cd ../..
rm -rf tcl8.6.8




#***********************************************************************************************
# 5.12. Expect-5.45.4
tar -xf expect5.45.4.tar.gz
cd expect5.45.4

cp -v configure{,.orig}
sed 's:/usr/local/bin:/bin:' configure.orig > configure

./configure --prefix=/tools \
 --with-tcl=/tools/lib \
 --with-tclinclude=/tools/include

make -j$CORE_COUNT
make SCRIPTS="" install

cd ..
rm -rf expect5.45.4




#***********************************************************************************************
# 5.13. DejaGNU-1.6.1
tar -xf dejagnu-1.6.1.tar.gz
cd dejagnu-1.6.1

./configure --prefix=/tools
make install

cd ..
rm -rf dejagnu-1.6.1




#***********************************************************************************************
# 5.14. M4-1.4.18
tar -xf m4-1.4.18.tar.xz
cd m4-1.4.18

./configure --prefix=/tools

make -j$CORE_COUNT
make install

cd ..
rm -rf m4-1.4.18




#***********************************************************************************************
# 5.15. Ncurses-6.1
tar -xf ncurses-6.1.tar.gz
cd ncurses-6.1

sed -i s/mawk// configure
./configure --prefix=/tools \
 --with-shared \
 --without-debug \
 --without-ada \
 --enable-widec \
 --enable-overwrite

make -j$CORE_COUNT
make install

cd ..
rm -rf ncurses-6.1






#***********************************************************************************************
# 5.16. Bash-4.4.18
tar -xf bash-4.4.18.tar.gz
cd bash-4.4.18

./configure --prefix=/tools --without-bash-malloc

make -j$CORE_COUNT
make install
ln -sv bash /tools/bin/sh

cd ..
rm -rf bash-4.4.18




#***********************************************************************************************
# 5.17. Bison-3.0.4
tar -xf bison-3.0.4.tar.xz
cd bison-3.0.4

./configure --prefix=/tools

make -j$CORE_COUNT
make install

cd ..
rm -rf bison-3.0.4




#***********************************************************************************************
# 5.18. Bzip2-1.0.6
tar -xf bzip2-1.0.6.tar.gz
cd bzip2-1.0.6

make
make PREFIX=/tools install

cd ..
rm -rf bzip2-1.0.6




#***********************************************************************************************
# 5.19. Coreutils-8.29
tar -xf coreutils-8.29.tar.xz
cd coreutils-8.29

./configure --prefix=/tools --enable-install-program=hostname

make -j$CORE_COUNT
make install

cd ..
rm -rf coreutils-8.29




#***********************************************************************************************
# 5.20. Diffutils-3.6
tar -xf diffutils-3.6.tar.xz
cd diffutils-3.6

./configure --prefix=/tools

make -j$CORE_COUNT
make install

cd ..
rm -rf diffutils-3.6




#***********************************************************************************************
# 5.21. File-5.32
tar -xf file-5.32.tar.gz
cd file-5.32

./configure --prefix=/tools

make -j$CORE_COUNT
make install

cd ..
rm -rf file-5.32




#***********************************************************************************************
# 5.22. Findutils-4.6.0
tar -xf findutils-4.6.0.tar.gz
cd findutils-4.6.0

./configure --prefix=/tools

make -j$CORE_COUNT
make install

cd ..
rm -rf findutils-4.6.0




#***********************************************************************************************
# 5.23. Gawk-4.2.0
tar -xf gawk-4.2.0.tar.xz
cd gawk-4.2.0

./configure --prefix=/tools

make -j$CORE_COUNT
make install

cd ..
rm -rf gawk-4.2.0




#***********************************************************************************************
# 5.24. Gettext-0.19.8.1
tar -xf gettext-0.19.8.1.tar.xz
cd gettext-0.19.8.1

cd gettext-tools
EMACS="no" ./configure --prefix=/tools --disable-shared

make -C gnulib-lib
make -C intl pluralx.c
make -C src msgfmt
make -C src msgmerge
make -C src xgettext

cp -v src/{msgfmt,msgmerge,xgettext} /tools/bin

cd ../..
rm -rf gettext-0.19.8.1




#***********************************************************************************************
# 5.25. Grep-3.1
tar -xf grep-3.1.tar.xz
cd grep-3.1

./configure --prefix=/tools

make -j$CORE_COUNT
make install

cd ..
rm -rf grep-3.1




#***********************************************************************************************
# 5.26. Gzip-1.9
tar -xf gzip-1.9.tar.xz
cd gzip-1.9

./configure --prefix=/tools

make -j$CORE_COUNT
make install

cd ..
rm -rf gzip-1.9




#***********************************************************************************************
# 5.27. Make-4.2.1
tar -xf make-4.2.1.tar.bz2
cd make-4.2.1

sed -i '211,217 d; 219,229 d; 232 d' glob/glob.c

./configure --prefix=/tools --without-guile

make -j$CORE_COUNT
make install

cd ..
rm -rf make-4.2.1





#***********************************************************************************************
# 5.28. Patch-2.7.6
tar -xf patch-2.7.6.tar.xz
cd patch-2.7.6

./configure --prefix=/tools

make -j$CORE_COUNT
make install

cd ..
rm -rf patch-2.7.6




#***********************************************************************************************
# 5.29. Perl-5.26.1
tar -xf perl-5.26.1.tar.xz
cd perl-5.26.1

sh Configure -des -Dprefix=/tools -Dlibs=-lm

make -j$CORE_COUNT

cp -v perl cpan/podlators/scripts/pod2man /tools/bin
mkdir -pv /tools/lib/perl5/5.26.1
cp -Rv lib/* /tools/lib/perl5/5.26.1

cd ..
rm -rf perl-5.26.1




#***********************************************************************************************
# 5.30. Sed-4.4
tar -xf sed-4.4.tar.xz
cd sed-4.4

./configure --prefix=/tools

make -j$CORE_COUNT
make install

cd ..
rm -rf sed-4.4




#***********************************************************************************************
# 5.31. Tar-1.30
tar -xf tar-1.30.tar.xz
cd tar-1.30

./configure --prefix=/tools

make -j$CORE_COUNT
make install

cd ..
rm -rf tar-1.30




#***********************************************************************************************
# 5.32. Texinfo-6.5
tar -xf texinfo-6.5.tar.xz
cd texinfo-6.5

./configure --prefix=/tools

make -j$CORE_COUNT
make install

cd ..
rm -rf texinfo-6.5




#***********************************************************************************************
# 5.33. Util-linux-2.31.1
tar -xf util-linux-2.31.1.tar.xz
cd util-linux-2.31.1

./configure --prefix=/tools \
 --without-python \
 --disable-makeinstall-chown \
 --without-systemdsystemunitdir \
 --without-ncurses \
 PKG_CONFIG=""

make -j$CORE_COUNT
make install

cd ..
rm -rf util-linux-2.31.1





#***********************************************************************************************
# 5.34. Xz-5.2.3
tar -xf xz-5.2.3.tar.xz
cd xz-5.2.3

./configure --prefix=/tools

make -j$CORE_COUNT
make install

cd ..
rm -rf xz-5.2.3





