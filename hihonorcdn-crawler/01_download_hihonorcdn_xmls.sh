#!/bin/sh

# Script tries to find all update files on update.hihonorcdn.com (filelist.xml & changelog.xml) and
# stores those files into update_hihonorcdn_com_all_* directory for further processing

from=920000
to=980000

d="update_hihonorcdn_com_all"

worker() {
    start=$1
    end=$2
    d2="$d/${start}_${end}"
    echo "Running worker ${start}_${end}";
    mkdir -p "$d2"
    for i in `seq $start 1 $end`; do
        echo "Getting v${i}";
        path="$d2/v${i}_filelist.xml"
        [ ! -f "$path" ] || continue
        curl -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/141.0' -so "${path}" http://update.hihonorcdn.com/TDS/data/bl/files/v$i/f1/full/filelist.xml
        if ! (grep '<packageType>full</packageType>' "${path}"); then
            rm -f "${path}"
        fi
    done
    echo "Worker done ${start}_${end}";
}

prev=''
for thread in `seq $from 20000 $to`; do
    if [ "x$prev" != 'x' ]; then
        worker $(($prev+1)) $thread &
    fi
    prev=$thread
done

wait

echo "Done"
