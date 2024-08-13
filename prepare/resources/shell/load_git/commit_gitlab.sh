#!/bin/bash
set -e

# 输出 commit

function help() {
    echo "usage:"
    echo "$(basename $0) -u URL [-t TAG]"
    echo "    -u \"https://gitlab/org/project.git\" 项目URL"
    echo "    -t \"v1.2.3\" | \"master\" tag 或 branch 名称"
    echo "    -h 打印帮助信息"
    exit
}

function get_project_id() {
    baseurl="$1"
    full_path="$2"
    query_data='{"query": "query {project(fullPath: \"'$full_path'\") { id }}"}'
    project_id=$(curl -s "$baseurl/api/graphql" --request POST \
        --header "Content-Type: application/json" \
        --data "$query_data" | sed -r 's#.*/([0-9]+)".*#\1#')
    echo $project_id
}

function get_commit() {
    baseurl="$1"
    project_id="$2"
    tag="$3"
    query_url_t="$baseurl/api/v4/projects/$project_id/repository/tags/$tag"
    query_url_b="$baseurl/api/v4/projects/$project_id/repository/branches/$tag"
    commit=$(curl -s "$query_url_t" | sed -r 's#.*commit/([0-9a-f]+)".*#\1#')
    if grep -q '{"message":"404 Tag Not Found"}' <<<"$commit"; then
        commit=$(curl -s "$query_url_b" | sed -r 's#.*commit/([0-9a-f]+)".*#\1#')
    fi
    echo $commit
}

function get_default_branch {
    baseurl="$1"
    project_id="$2"
    query_url="$baseurl/api/v4/projects/$project_id"
    default_branch=$(curl -s "$query_url" | sed -r 's#.*branch":"([^"]+)".*#\1#')
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
base=$(echo $url | sed -r 's#^(http[s]?://[^/]+)/([^/]+/[^/]+).*#\1#')
path=$(echo $url | sed -r 's#^(http[s]?://[^/]+)/([^/]+/[^/]+).*#\2#')

id=$(get_project_id "$base" "$path")
if [ -z "$tag_name" ]; then
    tag_name=$(get_default_branch "$base" "$id")
fi
tag_name=${tag_name//\//%2F}
commit=$(get_commit "$base" "$id" "$tag_name")

echo $commit
