#!/bin/bash
set -e


#


info="$(realpath $1)"
git_list="$(realpath $2)"
pkg_list="$(realpath $3)"
build_sh="$(realpath $4)"
output="$5"

# dir 玲珑项目根目录
dir=$(cd $(dirname $0);pwd)
dir=${dir%/prepare*}
replace="$dir/prepare/resources/shell/gen_yaml/replace.sh"
load_git="$dir/prepare/resources/shell/load_git/load_git.sh"
load_pkg="$dir/prepare/resources/shell/load_pkg/load_pkg.sh"
load_build="$dir/prepare/resources/shell/load_build/load_build.sh"
yaml_tmpl="$dir/prepare/resources/file/template/ll_tmpl.yaml"

temp_yaml=$(mktemp)
cp $yaml_tmpl $temp_yaml
bash $replace $info $temp_yaml
bash $load_git $git_list $temp_yaml
bash $load_pkg $pkg_list $temp_yaml
bash $load_build $git_list $build_sh $temp_yaml
cp $temp_yaml "$output"
rm -r "$temp_yaml"

sed -i '/##/d' "$output"
