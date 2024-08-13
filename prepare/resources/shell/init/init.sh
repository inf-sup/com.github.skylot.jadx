#!/bin/bash
set -e


# 项目初始化


# dir 玲珑项目根目录
dir=$(cd $(dirname $0); pwd)
dir=${dir%/prepare*}

# 初始化根目录
if ls "$dir" | grep -vq '^prepare$\|^\.git$\|^README\.md$'; then
    echo "ERROR: ($(basename $0)) 根目录已初始化!"
    exit -1
fi
cp -r "$dir/prepare/resources/file/base/." "$dir"

# 初始化 workdir
workdir="$dir/prepare/workdir"
if [ -d "$workdir" ]; then
    echo "ERROR: ($(basename $0)) workdir 已初始化!"
    exit -1
fi
mkdir "$workdir"
cp -r "$dir/prepare/resources/file/workdir/." "$workdir"
ln -s "../resources/shell/fini/fini.sh" "$workdir/fini.sh"
ln -s "../resources/shell/run/run.sh" "$workdir/run.sh"

