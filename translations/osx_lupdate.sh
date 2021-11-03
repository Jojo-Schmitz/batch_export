#!/bin/bash
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
    echo -ne "\n=========\n\033[31mPath to lupdate not found.\033[0m\nPlease provide a path to /Qt/(version)/clang_64/bin.\n"
    read excute_path
done

confirm_flag=0

until [ $confirm_flag -eq 1 ]; do
    full_lang_code="locale_"
    read -rp "Input your language code: " lang_code
    full_lang_code+=$lang_code
    echo -ne "Your ts file name is \033[33m${full_lang_code}.ts\033[0m\nConfirm? (y/n) "
    read confirm
    if [[ $confirm == "y" || $confirm == "yes" || $confirm -eq 1 ]]; then
        confirm_flag=1
    fi
done

${excute_path}/lupdate $(dirname $(dirname $0)) -no-obsolete -locations absolute -ts ${this_location}/${full_lang_code}.ts

echo finished
Countdown 10
exit
