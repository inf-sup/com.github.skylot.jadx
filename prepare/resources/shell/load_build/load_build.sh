#!/bin/bash
set -e


#


git_list=$(realpath $1)
build_sh=$(realpath $2)
yaml=$(realpath $3)

flag_start='## build-body'
flag_end='## build-body\/'


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
    echo "ERROR: ($(basename $0))"
    exit -1
fi

# dir 玲珑项目根目录
dir=$(cd $(dirname $0); pwd)
dir=${dir%/prepare*}

fill_build="$dir/prepare/resources/shell/load_build/fill_build.sh"

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

bash $fill_build $git_list $build_sh
sed -i '/## build-from-source/d' $build_sh
cp $build_sh $bp
sed -i 's/^/  &/g' $bp
cat $ap $bp $cp > $yaml

rm -r "$temp_dir"
