# SGX
Install SGX on clean Ubuntu 18.04

Go to BIOS
Enable SGX hardware mode
Disable Secure Boot

**Download and Install Driver**
1. sudo apt update
2. sudo apt install build-essential
3. sudo apt install git
4. sudo git clone https://github.com/intel/linux-sgx-driver.git
5. cd linux-sgx-driver
6. sudo make
7. sudo mkdir -p "/lib/modules/"`uname -r`"/kernel/drivers/intel/sgx"    
8. sudo cp isgx.ko "/lib/modules/"`uname -r`"/kernel/drivers/intel/sgx"    
9. sudo sh -c "cat /etc/modules | grep -Fxq isgx || echo isgx >> /etc/modules"    
10. sudo /sbin/depmod
11. sudo /sbin/modprobe isgx
Driver is installed here: /opt/intel/sgxdriver/

**Install Docker and Docker Compose**
1. sudo apt-get update
2. sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
3. echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
4. sudo apt-get update
5. sudo apt-get install docker-ce docker-ce-cli containerd.io
6. sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
7. sudo chmod +x /usr/local/bin/docker-compose
8. docker-compose --version

**Install SGX SDK and PSW**
1. sudo git clone https://github.com/intel/linux-sgx.git
3. cd linux-sgx
4. sudo make preparation
5. cd docker/build && sudo ./build_compose_run.sh
