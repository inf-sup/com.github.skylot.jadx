#!/bin/bash
set -e


# 下载 Packages 和 Contents 并提取信息


# dir 玲珑项目根目录
dir=$(cd $(dirname $0); pwd)
dir=${dir%/prepare*}
# pkg_dir 软件包信息存储目录
pkg="$dir/prepare/resources/file/package"
pkg_p="$pkg/Packages"
pkg_c="$pkg/Contents"

url='https://mirrors.ustc.edu.cn/deepin/beige'
distribution='beige'
components='main community'
arch='amd64'

# 下载 Packages
if [ ! -f $pkg_p ]; then
    for component in $components; do
       curl -sL "$url/dists/$distribution/$component/binary-$arch/Packages" >> $pkg_p
    done
    sed -i -n '/^Package/p;
               /^Version/p;
               /^Depends/p;
               /^Filename/p;
               /^SHA256/p;
               /^$/p' $pkg_p
    sed -i 's/([^()]*)//g' $pkg_p
    sed -i 's/:any//g' $pkg_p
fi
# 下载 Contents
# 解析依赖用, 暂无
#if [ ! -f $pkg_c ]; then
#    for component in $components; do
#        curl -sL "$url/dists/$distribution/$component/Contents-$arch.bz2" | bunzip2 >> $pkg_c
#    done
#fi
