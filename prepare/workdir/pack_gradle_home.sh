#!/bin/bash
set -e

# 处理 gradle home


# ==================================================

# dir 玲珑项目根目录
dir=$(cd $(dirname $0);pwd)
dir=${dir%/prepare*}

temp_dir=$(mktemp -d)
mkdir -p $temp_dir/gradle

GRADLE_USER_HOME="$dir/linglong/sources/gradle"
cd "$GRADLE_USER_HOME"
#cp -r --parents .tmp $temp_dir/gradle
cp -r --parents caches/modules-2/metadata-2*/descriptors $temp_dir/gradle
cp -r --parents caches/modules-2/metadata-2*/module* $temp_dir/gradle
cp caches/modules-2/metadata-2*/resource-at-url.bin $dir/prepare/workdir

cd $temp_dir
tar -zcf $dir/gradle.tar.gz gradle

rm -r "$temp_dir"