#!/bin/bash
set -e


# 从 $1 读取所需的pkg资源并插入 $2 中


pkg_list=$(realpath $1)
yaml=$(realpath $2)

# dir 玲珑项目根目录
dir=$(cd $(dirname $0); pwd)
dir=${dir%/prepare*}

insert="$dir/prepare/resources/shell/utils/insert.sh"
fill_pkg="$dir/prepare/resources/shell/load_pkg/fill_pkg.sh"

pkg_src=$(mktemp)

bash $fill_pkg $pkg_list $pkg_src
bash $insert -s $pkg_src -t $yaml -f '  ## pkg-source,  ## pkg-source\/'

rm "$pkg_src"
