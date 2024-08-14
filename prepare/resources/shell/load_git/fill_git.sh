#!/bin/bash
set -e


# 从 $1 中逐行读取git信息并以linglong.yaml中的下载格式输出


git_list=$(realpath $1)
output=$(realpath $2)
echo -n '' > "$output"

# dir 玲珑项目根目录
dir=$(cd $(dirname $0); pwd)
dir=${dir%/prepare*}

# load_git dir
cur_dir="$dir/prepare/resources/shell/load_git"
# commit
commit_github="$cur_dir/commit_github.sh"
commit_gitlab="$cur_dir/commit_gitlab.sh"

# 读取git.list文件
while IFS= read -r line; do
    # 读入 name url version commit
    if [ "${line:0:1}" == '[' ]; then
        unset -v name url version commit u v c
        name="${line#[}"
        name="${name%]}"
    elif [ "${line:0:4}" == 'url=' ]; then
        url="${line#*=}"
        u="set"
    elif [ "${line:0:8}" == 'version=' ]; then
        version="${line#*=}"
        v="set"
        if grep -qE '^[0-9]+$' <<< "$version";then version="\"$version\"";fi
    elif [ "${line:0:7}" == 'commit=' ]; then
        commit="${line#*=}"
        c="set"
    fi
    # 输出至 output $2
    if [ -n "$name" ] && [ -n "$u" ] && [ -n "$v" ]; then
        # TODO 处理version为空
        if [ -z "$commit" ]; then
            if echo "$url" | grep -q 'github\.com'; then
                commit=$(bash $commit_github -u $url -t \"$version\")
            elif echo "$url" | grep -q 'invent\.kde\.org\|gitlab'; then
                commit=$(bash $commit_gitlab -u $url -t \"$version\")
            fi
        fi
        if [ -n "$commit" ]; then
            {
                echo "  # $name"
                echo "  - kind: git"
                echo "    url: $url"
                echo "    version: $version"
                echo "    commit: $commit"
            } >> "$output"
            unset -v name url version commit u v c
        fi
    fi
done < <(cat "$git_list" | grep . | sed '/^#/d')
