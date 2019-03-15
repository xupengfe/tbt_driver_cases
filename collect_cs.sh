#!/bin/bash -e

DEST=$1
KERNEL_BUILD=$2

GCDA=/sys/kernel/debug/gcov

if [ -z "$KERNEL_BUILD" ] ; then
          echo "Usage: $0   code_scan kernel_path" >&2
          echo "$1: code_scan folder will be created like:xxx_code_scan"
          echo "$2: kernel compile path like:/home/otc_eywa-linux-eywa"
          exit 1
    fi

    [ -e "$DEST" ] && rm -rf "$DEST"
    mkdir $DEST
    TEMPDIR=$(mktemp -d)
    echo Collecting data..
    find $GCDA -type d -exec mkdir -p $TEMPDIR/\{\} \;
    find $GCDA -name '*.gcda' -exec sh -c 'cat < $0 > '$TEMPDIR'/$0' {} \;
    find $GCDA -name '*.gcno' -exec sh -c 'cp -d $0 '$TEMPDIR'/$0' {} \;
    tar czf $DEST/gcov.gz -C $TEMPDIR sys
    rm -rf $TEMPDIR

    echo "$DEST/gcov.gz successfully created, copy to build system and unpack with:"
    echo " tar xfz $DEST/gcov.gz"
    cd $DEST
    tar xfz gcov.gz
    cd ..

    sleep 1
    rm -rf /tmp/test.info
    sleep 1
    lcov --no-external --capture --base-directory $KERNEL_BUILD --directory $DEST --output-file /tmp/test.info
    [ $? -eq 0 ] || echo "lcov failed!"
    sleep 2
    html_path=html_"$DEST"
    [ -e "$html_path" ] && rm -rf $html_path
    mkdir "$html_path"
    genhtml --output-directory $html_path  /tmp/test.info
    if [ $? -eq 0 ]; then
      echo "genhtml success!"
    else
      echo "genhtml failed!"
      exit 1
    fi
    sleep 1
    tar -cvf "$html_path".tar $html_path
    sleep 1
    echo "Folder $html_path compress into '$html_path'.tar"

