#!/bin/bash

#  GenDummy.sh
#  SEVPN
#
#  Created by Shuyi Dong on 2018-09-09.
#

list=($(find ../Mayaqua/*.h) $(find ../Cedar/*.h))

file="./SENE/DummyFunction.c"

function func_file {
    found=0
    cat $2 | while IFS=$'\n' read -r line; do
        if [[ $found -eq 0 ]];then
            if [[ ! $line =~ '#' ]] && [[ ! $line =~ \\ ]] && [[ ! -z $(echo $line | grep -R "[ *]$1(") ]]; then
                found=1
                echo "$line"
                (>&2 echo "$line")
            fi
        else
            echo "$line"
        fi
        if [[ $found == 1 ]] && [[ $line =~ ";" ]]; then
            return 0
        fi
    done
    return 1
}

if [ ! -f ./SENE/DummyFunction.c ]; then
cat << EOF >> $file
#define SWIFT_BRIDGE

#include "CedarPch.h"

void* unimplemented(){ return 0x1; }
void* ignored(){ return 0x1; }

EOF
fi

for func in $(sed -E '/^[^"].*$/d; s/"_([^"]+)".*/\1/' < ./SENE/DummyCode/ld.src ); do
    if [[ ! -z $(grep -R "[ *]$func(" "$file") ]]; then
        echo "skipping $func"
        continue
    fi
    echo $func
    for f in "${list[@]}"; do
        proto=$(func_file $func $f)
        if [[ ! -z $proto ]];then
#echo "$proto" >> $file
            break 1
        fi
    done
    if [[ -z $proto ]];then
        echo function not found $func
        continue
    fi
    printf "$(echo -n "${proto//;}")\n" >> $file
    if [[ -z $(grep -R "void\s\+\w" - <<< $proto) ]]; then
        echo "{ return unimplemented(); }" >> $file
    else
        echo "{ unimplemented(); }" >> $file
    fi
    echo "" >> $file
done

echo "" > ./SENE/DummyCode/ld.src
