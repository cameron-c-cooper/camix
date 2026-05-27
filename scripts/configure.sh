#!/bin/sh
input="$1"
output="$2"

{
    echo "/* Auto-generated from $input — do not edit */"
    echo "#ifndef CONFIG_H"
    echo "#define CONFIG_H"
    echo ""
    while IFS='=' read -r key value; do
		#							leading and trailing whitespace strip
        key=$(echo "$key" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
        case "$key" in
            ''|'#'*) continue ;;
        esac
        case "$value" in
            1|y|Y) echo "#define $key 1" ;;
            0|n|N) echo "/* $key is not set */" ;;
            *)     echo "#define $key $value" ;;
        esac
    done < "$input"
    echo ""
    echo "#endif"
} > "$output"
