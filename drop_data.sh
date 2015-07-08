#!/bin/sh

# send async data to local collector bin in form of:
# drop_data.sh <DatabinID/name> key value <method> 

# then send data to server:
# drop_data.sh <DatabinID/name> --send 

# method used in case of data collision:
#   max - send only greatest
#   min - send smallest value
#   avg - send average
#   no value: send latest value


DROPDIR="/tmp/drop_data"
mkdir $DROPDIR 2> /dev/null

BID_NAME=$1
if [ -z $BID_NAME ]; then
    echo "can not continue"
    exit 1
fi

if [ -z $2 ]; then
    echo "invalid invocation"
    exit 1
fi

BID_ID=`grep -E "^${BID_NAME}\\ " /etc/drop_data.cfg | xargs | cut -d' ' -f2`
if [ -z $BID_ID ]; then
    BID=$BID_NAME;
else
    BID=$BID_ID
fi


METHOD=$4
if [ $2 != "--send" ]; then
    KEY=$2
    VAL=$3
    mkdir $DROPDIR/$BID 2>/dev/null
    echo $VAL >> $DROPDIR/$BID/$KEY
    echo $METHOD > $DROPDIR/${KEY}.method
    exit
fi


DDURL="https://datadrop.wolframcloud.com/api/v1.0/Add?bin=$BID"
if ! [ -f $DROPDIR/$BID ]; then
    echo "No data!"
    exit 1
fi

for key in `ls -1 $DROPDIR/$BID/`; do
    METHOD=`cat $DROPDIR/${key}.method`
    case "$METHOD" in
        min)
            data=`sort -n $DROPDIR/$BID/$key | head -n 1`
            ;;
        max)
            data=`sort -nr $DROPDIR/$BID/$key | head -n 1`
            ;; 
        avg)
            data=`awk '{sum+=sprintf("%d",$1)}END{printf "%d\n",sum/NR}' $DROPDIR/$BID/$key`
            ;;
        avgf)
            data=`awk '{sum+=sprintf("%f",$1)}END{printf "%.6f\n",sum/NR}' $DROPDIR/$BID/$key`
            ;;
        \?)
            echo "no such method: $METHOD"
            data=`tail -n 1 $DROPDIR/$BID/$key`
            ;;
        "")
            data=`tail -n 1 $DROPDIR/$BID/$key`
            ;;
        *)
            echo "UNKNOWN: $METHOD"
            data=`tail -n 1 $DROPDIR/$BID/$key`
            ;;
    esac
    DDURL="${DDURL}&${key}=${data}"
done

echo "Dropping data with $DDURL"
#wget $DDURL -q -O /dev/null
rm -rf $DROPDIR
wget -T 10 -t 5 $DDURL -q -O -
