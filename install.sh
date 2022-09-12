#!bin/bash

ROOT=/
TOP_DIR=$PWD
DIR_TMP=/tmp
DIR_SBIN=/sbin
DIR_OPT=/opt
DIR_INTEL=$DIR_OPT/intel
SDK=$DIR_INTEL/sgxsdk
PSW=$DIR_INTEL/sgxpsw
KERNEL=$(uname -r)
USER_NAME=$(logname)
SGX="/lib/modules/$KERNEL/kernel/drivers/intel/sgx"
DEPMOD=$DIR_SBIN/depmod
MODPROBE=$DIR_SBIN/modprobe
YELLOW=$(tput setaf 11)
RESET=$(tput sgr0)
GREEN=$(tput setaf 2)

#Install linux driver with user version
install_sgx_driver_version(){
        wget https://github.com/01org/linux-sgx-driver/archive/sgx_driver_$1.tar.gz && tar -xf sgx_driver_$1.tar.gz && cd linux-sgx-driver-*
	make && mkdir -p $SGX
        cp modules.order "/lib/modules/$KERNEL"
        cp isgx.ko $SGX
        sh -c "cat /etc/modules | grep -Fxq isgx || echo isgx >> /etc/modules"
	sh -c "cat /etc/modules | grep -Fxq isgx || echo isgx >> /etc/modules"
        $DEPMOD && $MODPROBE isgx
	rm -rf $DIR_TMP/*
}

#Install PSW and SDK with user version
install_sdk_psw_version(){
	wget https://github.com/01org/linux-sgx/archive/sgx_$1.tar.gz && tar -xf sgx_$1.tar.gz && cd linux-sgx-sgx_* && echo "$1" >> $DIR_INTEL/versao.txt
        ./download_prebuilt.sh && \
        make && make sdk_install_pkg && make psw_install_pkg &&\
        cd $DIR_TMP/linux-sgx-sgx_*/linux/installer/bin/ && \
        python -c "print 'no\n/opt/intel'" | ./sgx_linux_x64_sdk_*.bin && mkdir -p $SDK && \
        cp -r ./y/sgxsdk/* $SDK && \
        yes | ./sgx_linux_x64_psw_*.bin && \
	rm -rf $DIR_TMP/*
}

#Install linux driver
install_sgx_driver(){
        git clone https://github.com/01org/linux-sgx-driver.git && cd linux-sgx-driver
        make && mkdir -p $SGX
        cp modules.order "/lib/modules/$KERNEL"
        cp isgx.ko $SGX
        sh -c "cat /etc/modules | grep -Fxq isgx || echo isgx >> /etc/modules"
	sh -c "cat /etc/modules | grep -Fxq isgx || echo isgx >> /etc/modules"
        $DEPMOD && $MODPROBE isgx
	rm -rf $DIR_TMP/*
}

#Install PSW and SDK
install_sdk_psw(){
        git clone https://github.com/01org/linux-sgx.git && cd linux-sgx && \
	echo $output | git describe --tags | sed 's/.*_\([^-]*\)-.*$/\1/g' >> $DIR_INTEL/versao.txt
        ./download_prebuilt.sh && \
        make && make sdk_install_pkg && make psw_install_pkg &&\
        cd $DIR_TMP/linux-sgx/linux/installer/bin/ && \
        python -c "print 'no\n/opt/intel'" | ./sgx_linux_x64_sdk_*.bin && mkdir -p $SDK && \ 
        #cp -r ./y/sgxsdk/* $SDK && \
        yes | ./sgx_linux_x64_psw_*.bin && \
        rm -rf $DIR_TMP/*
}

#Install docker
install_docker(){
	wget -qO- https://get.docker.com/ | sh
	usermod -a -G docker $USER_NAME && service docker restart && id $USER_NAME
}

#Goto root dir
root_dir(){
	cd $DIR_TMP
}

#Goto top dir
top_dir(){
	cd $TOP_DIR
}

#Install dependencies
install_dependencies(){
	apt-get -qq -o=Dpkg::Use-Pty=0 update && apt-get -qq -o=Dpkg::Use-Pty=0 install -y software-properties-common
        add-apt-repository -y ppa:ubuntu-toolchain-r/test
        apt-get -qq -o=Dpkg::Use-Pty=0 update && apt-get -qq -o=Dpkg::Use-Pty=0 install -y git build-essential ocaml automake python autoconf libtool libcurl4-openssl-dev \
                                                 libprotobuf-dev libprotobuf-c0-dev protobuf-compiler curl make g++ unzip wget libssl$ \
                                                 software-properties-common g++-4.9 cmake nano vim
}

#Request SGX version
request_version(){
  	echo "${YELLOW}[INFO] Would you like to install the latest SGX version?[Y\N]${RESET}"
        read RESPONSE 
        if [ $(echo "$RESPONSE" |tr '[:lower:]' '[:upper:]') = "N" ]; then
                echo "${YELLOW}[INFO] Which SGX version would you like to install?[i.e 1.6|1.7]${RESET}"
                read VERSION
        fi
}


check_old_sgx(){
	ps -A -ww | grep [^]]isgx > $DIR_TMP/isgx.txt
	grep "$isgx" $DIR_TMP/isgx.txt
         if [ $? -ne 0  ] || [ -s ${SDK} ] || [ -s ${PSW} ]; then 
                echo "${YELLOW}[INFO] Uninstalling incompatible SGX versions...${RESET}"
                uninstall_sgx
                echo "${YELLOW}[INFO] Done.${RESET}"
        fi
	rm -f $DIR_TMP/isgx.txt
}


#Install specific version
check_version(){
	if [ -z "$VERSION"  ]; then
		check_old_sgx
		echo "${YELLOW}[INFO] Installing SGX Driver...${RESET}"
		root_dir
        	install_sgx_driver
        	echo "${YELLOW}[INFO] Done.${RESET}"
        	root_dir
        	echo "${YELLOW}[INFO] Installing SGX PSW and SDK...${RESET}"
        	install_sdk_psw
        	echo "${YELLOW}[INFO] Done.${RESET}"
	else
		check_old_sgx
		echo "${YELLOW}[INFO] Installing SGX Driver...${RESET}"
                root_dir
		install_sgx_driver_version "$VERSION"
                echo "${YELLOW}[INFO] Done.${RESET}"
                root_dir
                echo "${YELLOW}[INFO] Installing SGX PSW and SDK...${RESET}"
                install_sdk_psw_version "$VERSION"
                echo "${YELLOW}[INFO] Done.${RESET}"
	fi
#fi
}
