#!/bin/bash
set -e


# 从 $1 中逐行读取file信息并以linglong.yaml中的下载格式输出


file_list=$(realpath $1)
output=$(realpath $2)
echo -n '' > "$output"

# dir 玲珑项目根目录
dir=$(cd $(dirname $0); pwd)
dir=${dir%/prepare*}

cachedir="$dir/linglong/cache"
mkdir -p $cachedir

# 读取file.list文件
ln=0
while IFS= read -r line; do
    ln=$((ln+1))
    # 读入 url digest
    if [ "${line:0:4}" == "url=" ]; then
        unset -v url digest u d name
        url="${line#*=}"
        u="set"
    elif [ "${line:0:7}" == "digest=" ]; then
        digest="${line#*=}"
        d="set"
    fi
    # 输出至 output $2
    if [ -n "$url" ] && [ -n "$d" ]; then
        if [ -z "$digest" ]; then
            temp_dir=$(mktemp -d)
            cd "$temp_dir"
            #wget -q "$url"
            aria2c -x4 "$url" 1>&2
            hash_name=($(sha256sum ./* 2>/dev/null))
            if [ -z "$hash_name" ]; then
                echo "ERROR: ($(basename $0))"
                exit -1
            fi
            hash="${hash_name[0]}"
            name="${hash_name[1]##*/}"
            mv "./$name" "$cachedir/file_$hash"
            sed -i "$ln c digest=$hash" "$file_list"
            rm -r "$temp_dir" 
        else
            hash="$digest"
        fi
        {
            echo "  - kind: file"
            echo "    url: $url"
            echo "    digest: $hash"
        } >> "$output"
        unset -v u
    fi
done < <(cat "$file_list")
