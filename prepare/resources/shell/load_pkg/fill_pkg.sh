#!/bin/bash
set -e


# 从 $1 中逐行读取软件包并以linglong.yaml中的下载格式输出
# TODO 自动添加依赖


pkg_list=$1
output=$2
echo -n '' > $output

# dir 玲珑项目根目录
dir=$(cd $(dirname $0); pwd)
dir=${dir%/prepare*}
# pkg_dir 软件包信息存储目录
pkg_dir="$dir/prepare/resources/file/package"
pkg_p="$pkg_dir/Packages"
pkg_c="$pkg_dir/Contents"

url='https://mirrors.ustc.edu.cn/deepin/beige'
distribution='beige'
components='main community'
arch='amd64'

# 删除空行和冒号
sed -i '/^$/d' "$pkg_list"
sed -i 's/://g' "$pkg_list"

# 读取所需的软件包列表, 如果没有则退出
pkgs=$(cat "$pkg_list" | sed '/^#/d' | tr '\n' ',' | sed 's/,$//g')
[ -z "$pkgs" ] && exit

# 如果没有软件包信息则下载
if [ ! -f "$pkg_p" ] || [ ! -f "$pkg_c" ];then
    bash "$dir/prepare/resources/shell/load_pkg/dl_pkg_info.sh"
fi

# 添加包
echo "  # packages: $pkgs" >> "$output"
echo $pkgs | tr ',' '\n' | while IFS= read -r pkg; do
    info=$(
        awk '
        /^Package: '$pkg'$/ { find_pkg = 1 }
        /^$/                { find_pkg = 0 }
        /^Filename:/ {if (find_pkg) { filename = $2 }}
        /^SHA256:/   {if (find_pkg) {     hash = $2 }}
        END { printf "%s,%s", filename, hash }' $pkg_p
    )
    download_url="$url/$(awk -F, '{print $1}' <<< $info)"
    sha256=$(awk -F, '{print $2}' <<< $info)
    if [ -z "$sha256" ]; then
        echo "WARNING: ($(basename $0)) CAN'T FIND PACKAGE: $pkg"
        echo "  # PACKAGE '$pkg' NOT FOUND!" >> "$output"
        continue
    fi
    {
        echo "  - kind: file"
        echo "    url: $download_url"
        echo "    digest: $sha256"
    } >> "$output"
done
