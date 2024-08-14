#!/bin/bash
set -e

function help() {
    echo "usage:"
    echo "$(basename $0) -s SOURCE -t TARGET -f FLAG [-F]"
    echo "    -s SOURCE 源文件, 存放待添加的内容"
    echo "    -t TARGET 目标文件"
    echo "    -f 'begin,end' 开始和结束标志"
    echo "    -F 保留开始和结束标志"
    echo "    -h 打印帮助信息"
    exit
}

unset -v source target flags pflag
pflag=0

while getopts 'hs:t:f:F' OPT; do
    case $OPT in
    s) source="$OPTARG" ;;
    t) target="$OPTARG" ;;
    f) flags="$OPTARG" ;;
    F) pflag=1 ;;
    h) help ;;
    ?) help ;;
    esac
done

flag_begin=${flags%,*}
flag_end=${flags#*,}

err=$(awk '
    BEGIN { b = 0; e = 0; err = 1 }
    /^'"$flag_begin"'$/ {
        if ( b == 0 ) { b = NR }
        else { err = 2 }
    }
    /^'"$flag_end"'$/ {
        if ( e == 0 ) { e = NR }
        else { err = 3 }
    }
    END {
        if ( e > b && b > 0 && err == 1 ) { err = 0 }
        printf "%d", err
    }
' $target)
if [ $err -gt 0 ]; then
    echo "ERROR: ($(basename $0))"
    exit -1
fi

temp_dir=$(mktemp -d)
ap="$temp_dir/ap"
bp="$temp_dir/bp"
cp="$temp_dir/cp"
touch $ap $bp $cp

awk '
    BEGIN { f=0 }
    /'"$flag_begin"'$/ { f=2-'"$pflag"' }
    /'"$flag_end"'$/   { f=3+'"$pflag"' }
    f<=1 { print $0 > "'"$ap"'" }
    f==4 { print $0 > "'"$cp"'" }
    f==1||f==3 { f++ }
' $target

# 处理 SOURCE 不以换行结尾的情况
awk '{printf "%s\0", $0}' $source | xargs -0 -I% echo % >> $bp
cat $ap $bp $cp > $target

rm -r $temp_dir