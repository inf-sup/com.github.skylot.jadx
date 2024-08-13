#!/bin/bash
set -e

function help() {
    echo "usage:"
    echo "$(basename $0) -b|-r|-e [-y] [-C] [-O] [-h]"
    echo "    -b 运行 ll-builder build 进行构建"
    echo "    -r 运行 ll-builder run 运行玲珑程序"
    echo "    -e 运行 ll-builder export -l 导出layer包"
    echo "    -y 重新生成 linglong.yaml"
    echo "    -C build时使用 --skip-commit-output 参数"
    echo "    -O build时使用 --offline 参数"
    echo "    -B run时使用 --exec bash 参数"
    echo "    -h 打印帮助信息"
    exit
}

unset -v mode yaml build_option run_option offline
while getopts 'hbreyCOB' OPT; do
    case $OPT in
    b) mode="build" ;;
    r) mode="run" ;;
    e) mode="export" ;;
    y) yaml="true" ;;
    C) build_option="$build_option  --skip-commit-output" ;;
    O) build_option="$build_option  --offline"; offline="true" ;;
    B) run_option="$run_option  --exec bash" ;;
    h) help ;;
    ?) help ;;
    esac
done

# dir 玲珑项目根目录
dir=$(cd $(dirname $0);pwd)
dir=${dir%/prepare*}
cd $dir

gen_yaml="$dir/prepare/resources/shell/gen_yaml/gen_yaml.sh"
info="$dir/prepare/workdir/project.info"
git_list="$dir/prepare/workdir/git.list"
pkg_list="$dir/prepare/workdir/pkg.list"
build_sh="$dir/prepare/workdir/build.sh"

if [ -n "$yaml" ]; then
    bash $gen_yaml $info $git_list $pkg_list $build_sh "$dir/linglong.yaml"
fi

case $mode in
build)
    if [ -z "$offline" ]; then
        eval rm -rf "$dir/linglong/sources/*.deb"
    fi
    sh="ll-builder build $build_option"
    eval $sh
    ;;
run)
    sh="ll-builder run $run_option"
    eval $sh
    ;;
export)
    sh="ll-builder export -l"
    eval $sh
    ;;
*)
    echo "WARNING: ($(basename $0)) OPTION mode NOT SET"
    ;;
esac
