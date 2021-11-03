#!/bin/bash 
# C:/Qt/5.15.2/mingw81_64/bin/lrelease *.ts
# pause

this_location=$(dirname $0)

echo -ne "
    ╔══════════════════════════════════════╗
    ║                                      ║
    ║     Powered by David Copperfield     ║
    ║           A MuseScore User           ║
    ╚══════════════════════════════════════╝\n\n"

function Countdown() {
    countdown=$1
    while [ $countdown -gt 0 ]; do
        echo -ne "The programme will exit in $countdown sec."
        ((countdown--))
        sleep 1
        echo -ne "\r"
    done
}

excute_path=/$HOME/Qt/5.15.2/clang_64/bin

until [[ -d $excute_path ]]; do
    echo -ne "\n=========\n\033[31mPath to lrelease not found.\033[0m\nPlease provide a path to /Qt/(version)/clang_64/bin.\n"
    read excute_path
done
echo ${excute_path}/lrelease /*.ts
${excute_path}/lrelease ${this_location}/*.ts

echo finished
Countdown 10
exit

