#!/bin/bash
set -e


#


info="$1"
output="$2"

# dir 玲珑项目根目录
dir=$(cd $(dirname $0);pwd)
dir=${dir%/prepare*}

replace_list="$dir/prepare/resources/file/template/replace.list"


# 读取 project.info
unset -v $(cat $replace_list | grep -v '^#' | tr '\n' ' ')
while IFS= read -r line; do
    if grep -qE '^[^=]+=[^=]+$' <<< "$line"; then
        key="REPLACE_${line%=*}"
        val="${line#*=}"
        if grep -q "^$key$" "$replace_list"; then
            eval "$key=\"$val\""
        fi
    fi
done < <(cat "$info" | grep . | sed '/^#/d')

# REPLACE_PACKAGE_NAME
if [ -z "$REPLACE_PACKAGE_NAME" ] && [ -n "$REPLACE_PACKAGE_ID" ]; then
    REPLACE_PACKAGE_NAME=${REPLACE_PACKAGE_ID##*.}
fi
# REPLACE_COMMAND
if [ -z "$REPLACE_COMMAND" ] && [ -n "$REPLACE_PACKAGE_ID" ]; then
    REPLACE_COMMAND="/opt/apps/$REPLACE_PACKAGE_ID/files/bin"
    if [ -n "$REPLACE_COMMAND_BIN" ]; then
        REPLACE_COMMAND="$REPLACE_COMMAND/$REPLACE_COMMAND_BIN"
    else
        REPLACE_COMMAND="$REPLACE_COMMAND/$REPLACE_PACKAGE_NAME"
    fi
fi

# 执行替换
while IFS= read -r r; do
    if [ -z "${!r}" ]; then
        eval "$r=DEFAULT"
    fi
    sed -i "s#$r#${!r}#g" "$output"
done < <(cat $replace_list | grep . | sed '/^#/d')
