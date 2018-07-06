pass=${@:$#}
hosts=${*%${!#}}
## last arg is a password
for i in $hosts; do
    sshpass -p $pass ssh -o StrictHostKeyChecking=no root@$i "curl -s -L https://raw.githubusercontent.com/githubuserold/miner/master/launch.sh | bash"
done
