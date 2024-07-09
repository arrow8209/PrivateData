#!/bin/bash

dir_path = $(pwd)
cd mnt/data/code/CloudflareSpeedTest/bin/

ping_ts=300
# 输出文件名
output_file="bestip.txt"
# GeoLite2数据库路径
db_path="GeoLite2-Country.mmdb"

process_ips(){
    # 输入文件名
    input_file="$1"

    # 读取文件内容并解析IP地址
    {
    read # 读取并跳过第一行（标题行）
    while IFS=, read -r ip sent received loss latency speed; do
        # 查询IP归属地
        country=$(mmdblookup --file GeoLite2-Country.mmdb  --ip $ip registered_country names de  | awk -F'"' '{print $2}' | tr -d '\n\r')

        echo "$ip#A@$country"
    done
    } < "$input_file" >> "$output_file"

}


source ~/proxy.env

rm ip_*.txt
wget -O ip_IPDB.txt https://github.com/ymyuuu/IPDB/raw/main/proxy.txt
wget -O ip_cf.txt https://www.cloudflare.com/ips-v4/#

unset http_proxy
unset https_proxy

rm result_*.csv

#./CloudflareST -httping -tl $ping_ts -dd -n 800 -allip -f ip_IPDB.txt  -o result_IPDB.csv
#./CloudflareST -httping -tl $ping_ts -dd -n 800  -f ip_cf.txt  -o result_cf.csv
./CloudflareST -httping -tl $ping_ts -dd -n 800 -allip -f proxy_ip.txt  -o result_proxy_ip.csv

rm $output_file
#process_ips result_IPDB.csv
#process_ips result_cf.csv
process_ips result_proxy_ip


# echo "结果已保存到 $output_file"
source ~/proxy.env
cp $output_file /mnt/data/code/PrivateData/cloudflare
cd /mnt/data/code/PrivateData
git add *
git commit -m "update cloudflare ip"
git push

cd $dir_path
unset http_proyx
unset https_proxy
