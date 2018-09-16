


#***********************************************************************************************
#>>  which-2.21  << 
tar -xf which-2.21.tar.gz
cd which-2.21

./configure --prefix=/usr

make -j$CORE_COUNT
make install

cd ..
rm -rf which-2.21


#***********************************************************************************************
#>> openssh 7.8p1 << 
tar -xf openssh-7.8p1.tar.gz
cd openssh-7.8p1

install  -v -m700 -d /var/lib/sshd &&
chown    -v root:sys /var/lib/sshd &&

groupadd -g 50 sshd        &&
useradd  -c 'sshd PrivSep' \
         -d /var/lib/sshd  \
         -g sshd           \
         -s /bin/false     \
         -u 50 sshd

patch -Np1 -i ../openssh-7.8p1-openssl-1.1.0-1.patch &&

./configure --prefix=/usr                     \
            --sysconfdir=/etc/ssh             \
            --with-md5-passwords              \
            --with-privsep-path=/var/lib/sshd &&
make

make install &&
install -v -m755    contrib/ssh-copy-id /usr/bin     &&

install -v -m644    contrib/ssh-copy-id.1 \
                    /usr/share/man/man1              &&
install -v -m755 -d /usr/share/doc/openssh-7.8p1     &&
install -v -m644    INSTALL LICENCE OVERVIEW README* \
                    /usr/share/doc/openssh-7.8p1

cd ..
rm -rf openssh-7.8p1



#***********************************************************************************************
#>> wpa_supplicant-2.6 << 
http://www.linuxfromscratch.org/blfs/view/svn/basicnet/wpa_supplicant.html




#***********************************************************************************************
#>> Wireless Tools-29 << 
http://www.linuxfromscratch.org/blfs/view/svn/basicnet/wireless_tools.html




#***********************************************************************************************
#>> pyton six-1.11.0 << 
http://www.linuxfromscratch.org/blfs/view/svn/general/python-modules.html#six




#***********************************************************************************************
#>> libtasn1-4.13 << 
http://www.linuxfromscratch.org/blfs/view/svn/general/libtasn1.html




#***********************************************************************************************
#>> p11-kit-0.23.14 << 
http://www.linuxfromscratch.org/blfs/view/svn/postlfs/p11-kit.html




#***********************************************************************************************
#>> make-ca-0.9 << 
http://www.linuxfromscratch.org/blfs/view/svn/postlfs/make-ca.html




#***********************************************************************************************
#>> Wget-1.19.5 << 
http://www.linuxfromscratch.org/blfs/view/svn/basicnet/wget.html





#***********************************************************************************************
#>> libnl-3.4.0 << 
tar -xf libnl-3.4.0.tar.gz
cd libnl-3.4.0

./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --disable-static
make -j$CORE_COUNT

cd ..
rm -rf libnl-3.4.0



#***********************************************************************************************
#>> iw << 
tar -xf iw-4.9.tar.xz 
cd iw-4.9

make -j$CORE_COUNT
make install

cd ..
rm -rf iw-4.9




#***********************************************************************************************
#>> nano 2.9.8 << 
tar -xf nano-2.9.8.tar.xz
cd nano-2.9.8

./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --enable-utf8     \
            --docdir=/usr/share/doc/nano-2.9.8
make -j$CORE_COUNT
make install

cd ..
rm -rf nano-2.9.8

# copy existing configurations from centos



#***********************************************************************************************
#>> Popt-1.16 << 
http://www.linuxfromscratch.org/blfs/view/svn/general/popt.html




#***********************************************************************************************
#>> rsync-3.1.3 << 
http://www.linuxfromscratch.org/blfs/view/svn/basicnet/rsync.html




#***********************************************************************************************
#>> perl Error-0.17026 << 
http://www.linuxfromscratch.org/blfs/view/svn/general/perl-modules.html#perl-error




#***********************************************************************************************
#>> cURL-7.61.1 << 
http://www.linuxfromscratch.org/blfs/view/svn/basicnet/curl.html




#***********************************************************************************************
#>> Git-2.18.0 << 
http://www.linuxfromscratch.org/blfs/view/svn/general/git.html




#***********************************************************************************************
#>> usbutils-010 << 
http://www.linuxfromscratch.org/blfs/view/cvs/general/usbutils.html




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
