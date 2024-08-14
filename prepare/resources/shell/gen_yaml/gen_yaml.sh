#!/bin/bash
set -e


#


info="$(realpath $1)"
git_list="$(realpath $2)"
file_list="$(realpath $3)"
pkg_list="$(realpath $4)"
build_sh="$(realpath $5)"
output="$6"

# dir 玲珑项目根目录
dir=$(cd $(dirname $0);pwd)
dir=${dir%/prepare*}
replace="$dir/prepare/resources/shell/gen_yaml/replace.sh"
load_git="$dir/prepare/resources/shell/load_git/load_git.sh"
load_file="$dir/prepare/resources/shell/load_file/load_file.sh"
load_pkg="$dir/prepare/resources/shell/load_pkg/load_pkg.sh"
load_build="$dir/prepare/resources/shell/load_build/load_build.sh"
yaml_tmpl="$dir/prepare/resources/file/template/ll_tmpl.yaml"

temp_yaml=$(mktemp)
cp $yaml_tmpl $temp_yaml
bash $replace $info $temp_yaml
bash $load_git $git_list $temp_yaml
bash $load_file $file_list $temp_yaml
bash $load_pkg $pkg_list $temp_yaml
bash $load_build $git_list $build_sh $temp_yaml
cp $temp_yaml "$output"
rm -r "$temp_yaml"

sed -i '/##/d' "$output"
