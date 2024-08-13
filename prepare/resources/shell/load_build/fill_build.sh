#!/bin/bash
set -e


#


git_list=$(realpath $1)
yaml=$(realpath $2)

flag_start='## build-from-source'
flag_end='## build-from-source\/'


err=$(awk '
    BEGIN { s = 0; e = 0; err = 1 }
    /'"$flag_start"'$/ {
        if ( s == 0 ) { s = NR }
        else { err = 2 }
    }
    /'"$flag_end"'$/ {
        if ( e == 0 ) { e = NR }
        else { err = 3 }
    }
    END {
        if ( e > s && s > 0 && err == 1 ) { err = 0 }
        printf "%d", err
    }
' $yaml)

if [ $err -gt 0 ]; then
    #echo "ERROR: ($(basename $0))"
    exit
fi

# dir 玲珑项目根目录
dir=$(cd $(dirname $0); pwd)
dir=${dir%/prepare*}

temp_dir=$(mktemp -d)

ap="$temp_dir/ap"
bp="$temp_dir/bp"
cp="$temp_dir/cp"
touch $ap $bp $cp

awk '
    BEGIN { f=0 }
    /'"$flag_start"'$/ { f=1 }
    /'"$flag_end"'$/   { f=3 }
    f<=1 { print $0 > "'"$ap"'" }
    f==3 { print $0 > "'"$cp"'" }
    f==1 { f=2 }
' $yaml

# 读取git.list文件
while IFS= read -r line; do
    # 读入 name url
    if [ "${line:0:1}" == '[' ]; then
        unset -v name url
        name="${line#[}"
        name="${name%]}"
    elif [ "${line:0:4}" == 'url=' ]; then
        url="${line#*=}"
    fi
    # 输出至 $bp
    if [ -n "$name" ] && [ -n "$url" ]; then
        git_dir=${url##*/}
        {
            echo "# build $name"
            echo "cd /project/linglong/sources/$git_dir"
            echo ""
        } >> $bp
        unset -v name url
    fi
done < <(cat "$git_list" | grep . | sed '/^#/d')

cat $ap $bp $cp > $yaml

rm -r "$temp_dir"
