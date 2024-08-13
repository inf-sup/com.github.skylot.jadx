#!/bin/bash
set -e



# dir 玲珑项目根目录
dir=$(cd $(dirname $0);pwd)
dir=${dir%/prepare*}

packages_list="$dir/prepare/resources/file/package/Packages"
contents_list="$dir/prepare/resources/file/package/Contents"

# TODO 清除cache
[ -f "$packages_list" ] && rm $packages_list
[ -f "$contents_list" ] && rm $contents_list

# 设置.gitignore
sed -i 's/.dont_ignore_now$//g' "$dir/.gitignore"
