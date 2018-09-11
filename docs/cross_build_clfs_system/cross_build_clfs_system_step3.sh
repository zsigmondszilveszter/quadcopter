export CORE_COUNT=1


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



#***********************************************************************************************
#>> BC<<  

tar -xf bc-1.07.1.tar.gz
cd bc-1.07.1

cat > bc/fix-libmath_h << "EOF"
#! /bin/bash
sed -e '1 s/^/{"/' \
 -e 's/$/",/' \
 -e '2,$ s/^/"/' \
 -e '$ d' \
 -i libmath.h
sed -e '$ s/$/0}/' \
 -i libmath.h
EOF
ln -sv /ctools/lib/libncursesw.so.6 /usr/lib/libncursesw.so.6
ln -sfv libncurses.so.6 /usr/lib/libncurses.so
sed -i -e '/flex/s/as_fn_error/: ;; # &/' configure

./configure --prefix=/usr \
 --with-readline \
 --mandir=/usr/share/man \
 --infodir=/usr/share/info
make -j$(nproc)
make install

cd ..
rm -rf bc-1.07.1


#***********************************************************************************************
#>> Bzip <<

tar -xf bzip2-1.0.6.tar.gz
cd bzip2-1.0.6

patch -Np1 -i ../bzip2-1.0.6-install_docs-1.patch
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile

make -f Makefile-libbz2_so
make clean
make -j$CORE_COUNT
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
tar -xf 



#***********************************************************************************************
#>>  << 




#***********************************************************************************************
#>>  << 




#***********************************************************************************************
#>>  << 




#***********************************************************************************************
#>>  << 




#***********************************************************************************************
#>>  << 




#***********************************************************************************************
#>>  << 




#***********************************************************************************************
#>>  << 




#***********************************************************************************************
#>>  << 




#***********************************************************************************************
#>>  << 




#***********************************************************************************************
#>>  << 




#***********************************************************************************************
#>>  << 




#***********************************************************************************************
#>>  << 




#***********************************************************************************************
#>>  << 




#***********************************************************************************************
#>>  << 
