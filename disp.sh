#! /bin/bash
if test "`uname`" != "Linux"; then
    echo "This system is not supported."
    exit
fi
for index in `seq 0 $((${#0} -1))`; do
    if test "${0:$index:1}" == "/"; then
        end_path=$index
    fi
done
today=0
if test "${0:$(($end_path + 1))}" == "today"; then
    today=1
fi
gettime=0
if test "${0:$(($end_path + 1))}" == "gettime"; then
    gettime=1
fi
detect=`sudo i2cdetect -y 1 | grep "3e" | wc -l`
if test $detect -eq 0; then
    if test $gettime -eq 0; then
        echo "AQM0802 is not installed."
    fi
    exit
fi

device="0x3e"
send_command="0x00"
send_data="0x40"

init_first="0x38 0x39 0x14 0x70 0x56 0x6c i"
init_second="0x38 0x0d 0x01 i"

position_00="0x02 i"
position_10="0xc0 i"

function hexcode() {
    code=""
    if test ${#strings} -ne 0; then
        for index in `seq 0 $((${#strings} - 1))`; do
            code="$code 0x`printf "%x" \'${strings:$index:1}`"
        done
    fi
}

sudo i2cset -y 1 $device $send_command $init_first
sudo i2cset -y 1 $device $send_command $init_second
if test "$1" != ""; then
    strings=$1
else
    if test $gettime -eq 1; then
        strings=`date +%Y%m%d`
    elif test $today -eq 1; then
        strings=`date +%d-%a`
    else
        echo -n "Input first line > "
        read strings
    fi
fi
hexcode
sudo i2cset -y 1 $device $send_data $code i
sudo i2cset -y 1 $device $send_command $position_10
if test "$2" != ""; then
    strings=$2
else
    if test $gettime -eq 1; then
        strings=`date +%H:%M\ %a`
    elif test $today -eq 1; then
        strings=`date +%b-%Y`
    else
        echo -n "Input second line > "
        read strings
    fi
fi
hexcode
sudo i2cset -y 1 $device $send_data $code i
