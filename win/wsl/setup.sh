# P4 setup


### Connect to VcXsrv or GWSL2 X server
vim /etc/resolv.conf
# get the config then
vim /etc/wsl.conf
# add the content
[network]
generateResolvConf = false

# restart wsl
wsl --shutdown

vim .profile
# add this
export DISPLAY=$(ip route | grep default | awk '{print $3; exit;}'):0.0


### connect to phone squid proxy server running on termux with port 9999 
netsh interface portproxy delete v4tov4 listenport=9999 listenaddress=0.0.0.0
adb forward tcp:9999 tcp:9999
netsh interface portproxy add v4tov4 listenport=9999 listenaddress=0.0.0.0 connectport=9999 connectaddress=127.0.0.1

netsh interface portproxy delete v4tov4 listenport=5555 listenaddress=0.0.0.0

### phone
netsh interface portproxy delete v4tov4 listenport=8888 listenaddress=0.0.0.0
adb forward tcp:8888 tcp:8888
netsh interface portproxy add v4tov4 listenport=8888 listenaddress=0.0.0.0 connectport=8888 connectaddress=127.0.0.1

### sunshine tunnel
netsh interface portproxy add v4tov4 listenport=2222 listenaddress=0.0.0.0 connectport=2222 connectaddress=127.0.0.1

ssh -L 172.25.128.1:47989:100.99.0.1:47989 \
    -L 172.25.128.1:48010:100.99.0.1:48010 \
    -L 172.25.128.1:47998:100.99.0.1:47998 \
    -L 172.25.128.1:47989:100.99.0.1:47989 \
    -p 2222 u0_a327@172.25.128.1


### fw
socat TCP-LISTEN:47989,fork TCP:100.99.0.1:47989 &&\
socat TCP-LISTEN:48010,fork TCP:100.99.0.1:48010 &&\
socat UDP4-RECVFROM:47998,fork UDP4-SENDTO:localhost:47998

netsh interface portproxy delete v4tov4 listenport=47989 listenaddress=0.0.0.0
adb forward tcp:47989 tcp:47989
netsh interface portproxy add v4tov4 listenport=47989 listenaddress=0.0.0.0 connectport=47989 connectaddress=127.0.0.1

netsh interface portproxy delete v4tov4 listenport=47998 listenaddress=0.0.0.0
adb forward tcp:47998 tcp:47998
netsh interface portproxy add v4tov4 listenport=47998 listenaddress=0.0.0.0 connectport=47998 connectaddress=127.0.0.1




### Config proxy
#!/bin/bash
gateway_ip=$(ip route | grep default | awk '{print $3}')
echo $gateway_ip

export http_proxy=http://$gateway_ip:9999
export https_proxy=http://$gateway_ip:9999
export no_proxy="localhost,127.0.0.1"


### connect Xvfb 
[wsl2]
guiApplications=false

export GDK_BACKEND=x11; Xvfb :99 -screen 0 1920x1080x24
x11vnc -display :99

## DOCKER
# sudo docker build \
  --build-arg HTTP_PROXY=${http_proxy} \
  --build-arg HTTPS_PROXY=${https_proxy} \
  -t ub22 .

sudo systemctl daemon-reload#
sudo systemctl restart docker
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo vim /etc/systemd/system/docker.service.d/http-proxy.conf

glxinfo | grep "OpenGL renderer"
OpenGL renderer string: llvmpipe (LLVM 15.0.7, 256 bits)


#
FROM ubuntu:22.04

COPY setup.sh /
WORKDIR /app

    dpkg --add-architecture i386 &&\
    add-apt-repository ppa:deadsnakes/ppa &&\
    apt update &&\

RUN apt update &&\
    apt install -y software-properties-common &&\
    apt install -y git gnupg flex bison build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig libc6-dev libxml-simple-perl openjdk-11-jdk python3-networkx python3-cryptography python3-pil python3-lxml dpkg-dev libdrm-dev libtie-ixhash-perl libxml-twig-perl libxml-xpath-perl mesa-common-dev ant p7zip p7zip-full lzop gcc g++ gawk liblz4-tool doxygen diffstat texi2html texinfo chrpath intltool dos2unix libssl-dev bc pigz libswitch-perl gperf ccache lz4 csh uuid-dev binutils-aarch64-linux-gnu pkg-config make libncurses6 lib32ncurses6-dev x11proto-dev python2.7 libpython2.7 python2.7-minimal &&\
    echo 'Acquire::Queue-Mode "host";' > /etc/apt/apt.conf.d/99custom && \
    echo 'Acquire::http::Pipeline-Depth "200";' >> /etc/apt/apt.conf.d/99custom &&\
    /setup.sh && \
    apt clean && \

    apt install -y git gnupg flex bison build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig libc6-dev libxml-simple-perl openjdk-11-jdk python3-networkx python3-cryptography python3-pil python3-lxml dpkg-dev libdrm-dev libtie-ixhash-perl libxml-twig-perl libxml-xpath-perl mesa-common-dev ant p7zip p7zip-full lzop gcc g++ gawk liblz4-tool doxygen diffstat texi2html texinfo chrpath intltool dos2unix libssl-dev bc pigz libswitch-perl gperf ccache lz4 csh uuid-dev binutils-aarch64-linux-gnu pkg-config make &&\

COPY samsungdev-keyring-2018-rt.gpg /etc/apt/trusted.gpg.d/samsungdev-keyring-2018-rt.gpg
RUN echo "deb http://deb.repo.sec.samsung.net/samsungdev-debian jammy dpi" > /etc/apt/sources.list.d/samsungdev.sources.list && \
        apt update && \
        apt -y install samsungdev


# Run
sudo docker run -v /home/ntc/P4/SRV_DSS_BENI_A155F_cuong.nguyen_local:/app -it b2 /bin/bash


### HFS server
netsh interface portproxy delete v4tov4 listenport=8080 listenaddress=0.0.0.0
etsh interface portproxy add v4tov4 listenport=8080 listenaddress=0.0.0.0 connectport=8080 connectaddress=172.17.5.110
