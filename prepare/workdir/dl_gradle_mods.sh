#!/bin/bash
set -e

# 将 gradle 构建应用时所需的模块文件的信息记录下来


function get_res_info() {
    # in: resource-at-url.bin 文件
    in="$1"
    path="$2"
    url="$3"
    hd "$in" -e '32/1 "%_p"' | grep files | sed -E 's/\.{2,}/\n/g' | grep '^file' | sort | uniq > "$path"
    # 重定向
    #hd "$in" -e '32/1 "%_p"' | grep files | sed -E 's/\.{2,}/\n/g' | grep '^http' | xargs -I@ curl -sLI -w '%{url_effective}\n' -o /dev/null @ > "$url"
    # aliyun maven mirror
    hd "$in" -e '32/1 "%_p"' | grep files | sed -E 's/\.{2,}/\n/g' | grep '^http' | 
        sed -E 's#https://repo[0-9]?\.maven\.org/maven2/#https://maven\.aliyun\.com/repository/public/#g' |
        sed -E 's#https://jcenter\.bintray\.com/#https://maven\.aliyun\.com/repository/public/#g' |
        sed -E 's#https://repo\.maven\.apache\.org/maven2/#https://maven\.aliyun\.com/repository/public/#g' |
        sed -E 's#https://plugins\.gradle\.org/m2/#https://maven\.aliyun\.com/repository/gradle-plugin/#g' > "$url"
}


# ==================================================

# dir 玲珑项目根目录
dir=$(cd $(dirname $0);pwd)
dir=${dir%/prepare*}

temp_dir=$(mktemp -d)

res_at_url="$dir/prepare/workdir/resource-at-url.bin"
file_list="$dir/prepare/workdir/file.list"
res_path="$dir/res.list"
#res_url="$temp_dir/url.list"
res_url="$dir/prepare/workdir/url.list"

get_res_info $res_at_url $res_path $res_url

echo -e "url=https://mirrors.huaweicloud.com/openjdk/17.0.2/openjdk-17.0.2_linux-x64_bin.tar.gz\ndigest=" > $file_list
echo -e "url=https://mirrors.cloud.tencent.com/gradle/gradle-8.2-bin.zip\ndigest=" >> $file_list
cat $res_url | sort | uniq | xargs -I% echo -e "url=%\ndigest=" >> $file_list

rm -r "$temp_dir"