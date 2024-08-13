#!/bin/bash
set -e

# 输出 commit

function help() {
    echo "usage:"
    echo "$(basename $0) -u URL [-t TAG]"
    echo "    -u \"https://github/org/project.git\" 项目URL"
    echo "    -t \"v1.2.3\" | \"master\" tag 或 branch 名称"
    echo "    -h 打印帮助信息"
    exit
}

function get_commit() {
    baseurl='https://api.github.com'
    full_name="$1"
    tag="$2"
    query_url="$baseurl/repos/$full_name/commits/$tag"
    commit=$(curl -s "$query_url" | grep 'sha' | head -n 1 | sed -r 's#.*"sha": "([0-9a-f]+)".*#\1#')
    echo $commit
}

function get_default_branch {
    baseurl='https://api.github.com'
    full_name="$1"
    query_url="$baseurl/repos/$full_name"
    default_branch=$(curl -s "$query_url" | grep 'default_branch' | sed -r 's#.*"default_branch": "([^"]+)".*#\1#')
    echo $default_branch
}

unset -v http_url_to_repo tag_name
while getopts 'hu:t:' OPT; do
    case $OPT in
    u) http_url_to_repo="$OPTARG" ;;
    t) tag_name="${OPTARG//\"/}" ;;
    h) help ;;
    ?) help ;;
    esac
done

url=${http_url_to_repo//.git/}
path=$(echo $url | sed -r 's#^(http[s]?://[^/]+)/([^/]+/[^/]+).*#\2#')
if [ -z "$tag_name" ]; then
    tag_name=$(get_default_branch "$path")
fi
tag_name=${tag_name//\//%2F}
commit=$(get_commit "$path" "$tag_name")

echo $commit
