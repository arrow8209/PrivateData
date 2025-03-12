#!/bin/bash

dir_path=$(pwd)
cd /mnt/data/code/CloudflareSpeedTest/bin/

ping_ts=500
# 输出文件名
output_1="bestip1.txt"
output_2="bestip2.txt"
# GeoLite2数据库路径
db_path="GeoLite2-Country.mmdb"

count=0
process_ips(){
    # 输入文件名
    input_file="$1"
    output_file="$2"

    # 读取文件内容并解析IP地址
    {
    read # 读取并跳过第一行（标题行）
    while IFS=, read -r ip sent received loss latency speed; do
        # # 限制处理行数
        # if (( count >= 15 )); then
        #     break
        # fi

        # 查询IP归属地
        # registered_country=$(mmdblookup --file GeoLite2-Country.mmdb  --ip $ip registered_country iso_code  | awk -F'"' '{print $2}' | tr -d '\n\r')
        country=$(mmdblookup --file GeoLite2-Country.mmdb  --ip $ip country iso_code  | awk -F'"' '{print $2}' | tr -d '\n\r')

        # 输出2位count，高位补0
        padded_count=$(printf "%02d" $count)

        if [ -z "$country" ]; then
            country="UNKNOWN"
            echo "$ip#UNKNOWN $padded_count"
        else
            echo "$ip#$country $padded_count"
        fi
        
        # 自增数字
        count=$((count+1))
    done
    } < "$input_file" >> "$output_file"

}


source ~/proxy.env

rm ip_*.txt

#下载cf CDN节点IP
# wget -O ip_cf.txt https://www.cloudflare.com/ips-v4/#

#下载IPDB提供的代理IP
# wget -O ip_IPDB.txt https://github.com/ymyuuu/IPDB/raw/main/proxy.txt

unset http_proxy
unset https_proxy

rm result_*.csv

# ./CloudflareST -httping -tl $ping_ts -dd -n 800  -f ip_cf.txt  -o result_cf.csv
# ./CloudflareST -httping -tl $ping_ts -dd -n 800 -allip -f ip_IPDB.txt  -o result_IPDB.csv
# ./CloudflareST -httping -tl $ping_ts -dd -n 400 -allip -f proxy_ip.txt  -o result_proxy_ip.csv

# ./CloudflareST -httping -dd -tl $ping_ts -n 800 -allip -f ip_IPDB.txt  -o result_IPDB.csv
# ./CloudflareST -httping -dd -tl $ping_ts -n 400 -allip -f proxy_ip.txt -o result_proxy_ip.csv
#./CloudflareST -httping -dd -tl $ping_ts -n 400 -dn 20 -dt 5 -allip -f proxy_ip.cn2.txt -o result_proxy_ip.csv

#./CloudflareST -httping -dd -tl $ping_ts -n 400 -dn 20 -dt 5 -allip -url https://serv00.zzz01.cloudns.ch/ -f proxy_ip.cn2.txt -o result_proxy_ip.csv
#./CloudflareST -httping -dd -tl $ping_ts -n 400 -dn 20 -dt 5 -allip -url https://vl.zzz-family.cloudns.be/ -f proxy_ip.cn2.txt -o result_proxy_ip.csv
# ./CloudflareST -httping -tl $ping_ts -n 50 -dn 60 -dt 5 -allip -f proxy_ip.txt -o result_proxy_ip.csv -url https://cloudflare.cdn.openbsd.org/pub/OpenBSD/7.3/src.tar.gz

# ./CloudflareST -httping -dd -tl 400 -n 400 -dn 20 -dt 20 -allip -url http://s6.mimipig0917.serv00.net/ -f proxy_ip.cn2.txt -o result_proxy_ip_cn2.csv
./CloudflareST -httping -dd -tl 400 -n 400 -dn 20 -dt 20 -allip -url http://s6.mimipig0917.serv00.net/ -f proxy_ip.txt -o result_proxy_ip.csv

rm $output_1
rm $output_2

process_ips result_proxy_ip_cn2.csv $output_1
process_ips result_proxy_ip.csv $output_2

# cat $output_2 >> $output_1

# echo "结果已保存到 $output_file"
source ~/proxy.env
cp $output_1 /mnt/data/code/PrivateData/cloudflare
cp $output_2 /mnt/data/code/PrivateData/cloudflare
cd /mnt/data/code/PrivateData
git add *
git commit -m "update cloudflare ip"
git push

cd $dir_path
unset http_proyx
unset https_proxy
