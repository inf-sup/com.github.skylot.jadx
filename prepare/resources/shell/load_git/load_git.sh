#!/bin/bash
set -e


# 从 $1 读取所需的git资源并插入 $2 中


git_list=$(realpath $1)
yaml=$(realpath $2)

# dir 玲珑项目根目录
dir=$(cd $(dirname $0); pwd)
dir=${dir%/prepare*}

insert="$dir/prepare/resources/shell/utils/insert.sh"
fill_git="$dir/prepare/resources/shell/load_git/fill_git.sh"

git_src=$(mktemp)

bash $fill_git $git_list $git_src
bash $insert -s $git_src -t $yaml -f '  ## git-source,  ## git-source\/'

rm "$git_src"
