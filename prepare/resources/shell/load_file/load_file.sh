#!/bin/bash
set -e


# 从 $1 读取所需的file资源并插入 $2 中


file_list=$(realpath $1)
yaml=$(realpath $2)

# dir 玲珑项目根目录
dir=$(cd $(dirname $0); pwd)
dir=${dir%/prepare*}

insert="$dir/prepare/resources/shell/utils/insert.sh"
fill_file="$dir/prepare/resources/shell/load_file/fill_file.sh"

file_src=$(mktemp)

bash $fill_file $file_list $file_src
bash $insert -s $file_src -t $yaml -f '  ## file-source,  ## file-source\/'

rm "$file_src"
