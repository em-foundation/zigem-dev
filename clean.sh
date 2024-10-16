#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

deep="-d"
deepLong="--deep"
clean=$1

if [ "$clean" != "" ] && [ "$clean" != "$deep" ] && [ "$clean" != "$deepLong" ]; then
    echo "usage:  clean.sh [$deep, $deepLong]"
    echo default clean is zig-em workspace only
    echo $deep or $deepLong cleans zig-build artifacts and zig global cache as well
    exit 1
fi

echo clean workspace
rm -rf $SCRIPT_DIR/workspace/{zigem,.zigem-main.zig}

if [ "$clean" != "" ] ; then
    echo clean zig build artifacts
    rm -rf $SCRIPT_DIR/{.zig-cache,zig-out,zigem}

    echo clean zig global cache
    rm -rf $HOME/.cache/zig
fi
