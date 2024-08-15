#!/bin/bash
set -e

function get_res_info() {
    # in: resource-at-url.bin 文件
    in="$1"
    path="$2"
    url="$3"
    hd "$in" -e '32/1 "%_p"' | grep files | sed -E 's/\.{2,}/\n/g' | grep '^file' > "$path"
    hd "$in" -e '32/1 "%_p"' | grep files | sed -E 's/\.{2,}/\n/g' | grep '^http' > "$url"
}


# ==================================================

# dir 玲珑项目根目录
dir=$(cd $(dirname $0);pwd)
dir=${dir%/prepare*}

temp_dir=$(mktemp -d)

res_at_url="$dir/prepare/workdir/resource-at-url.bin"
file_list="$dir/prepare/workdir/file.list"
res_path="$dir/res.list"
res_url="$temp_dir/url.list"

get_res_info $res_at_url $res_path $res_url

echo -e "url=https://mirrors.huaweicloud.com/openjdk/17.0.2/openjdk-17.0.2_linux-x64_bin.tar.gz\ndigest=" > $file_list
echo -e "url=https://mirrors.cloud.tencent.com/gradle/gradle-8.7-bin.zip\ndigest=" >> $file_list
cat $res_url | uniq | xargs -I% echo -e "url=%\ndigest=" >> $file_list

rm -r "$temp_dir"