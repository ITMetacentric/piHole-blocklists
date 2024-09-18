#!/bin/bash

ROOTDIR=/home/isaac/blocklists
PIHOLE=$ROOTDIR/piHole_blocklists
LIST=/home/isaac/blocklists/Lists
YOUTUBE=/home/isaac/blocklists/youTube_ads_4_pi-hole
DIRECTORIES=("$LIST" "$YOUTUBE")

help()
{
    echo "A bash script to create the pihole blocklists"
    echo
    echo "Syntax: scriptTemplate [-u|h|c|g]"
    echo "options:"
    echo
    echo "h     Print this Help."
    echo "u     Clone and/or update the forks"
    echo "c     [USAGE]: -c include.txt."
    echo "       Create the unified lists, takes file for lists as argument."
    echo "g     Get the required repositories for the first time. Ignore any errors which may occur. These are just directories already existing"
    echo 
}

combined ()
{
    echo combinding files and spliting into deduplicated file...
    cd "$PIHOLE/Lists" || exit
    find . -name "*.txt" -type f -print0 | xargs -0 -n 1 -P 4 sed -i -e '$a\'
    wait
    find . -name '*.txt' ! -name 'temp.txt' -exec cat {} +  >> temp.txt
    wait
    cd "$PIHOLE/bin" || exit
    split -dl 400000 --additional-suffix=.txt "$PIHOLE/Lists/temp.txt" dedup-
    wait
    cd "$PIHOLE/Lists" || exit
    echo removing temp file
    rm temp.txt
}

create ()
{
    filename=$1
    echo Reading files...
    while IFS= read -r line; do
        files+=("$line")
    done < "$filename"
    echo Copying files...
    cp "$YOUTUBE/youtubelist.txt" "$PIHOLE/Lists"
    cp "$YOUTUBE/crowed_list.txt" "$PIHOLE/Lists"
    for file in "${files[@]}";
    do
        src="$LIST/$file"
        echo "$src"
        cp "$LIST/$file" "$PIHOLE/Lists"
        wait
    done
    combined
}

get()
{
    echo Retiriving the required repositories
    cd "$ROOTDIR" || exit
    name="$(basename "$LIST")"
    git clone "git@github.com:ITMetacentric/$name.git"
    wait
    cd "$name" || exit
    git remote add upstream https://github.com/blocklistproject/Lists.git
    cd "$ROOTDIR" || exit
    name="$(basename "$YOUTUBE")"
    git clone "git@github.com:ITMetacentric/$name.git"
    wait
    cd "$name" || exit
    git remote add upstream https://github.com/kboghdady/youTube_ads_4_pi-hole.git
    cd "$ROOTDIR" || exit
}

update()
{
    echo Updating from Remote Forks...
    cd "$ROOTDIR" || exit
    for dir in "${DIRECTORIES[@]}";
    do 
        echo Updating "$(basename "$dir")"
        cd "$dir" || exit
        git checkout master
        git fetch upstream
        git merge upstream/master
    done
    echo Done!
    echo Updating Main Repository...
    cd "$PIHOLE" || exit
    git pull main
    echo Done!
    echo Collecting external large lists
    cd "$PIHOLE"/Lists || exit
    curl -L https://nsfw.oisd.nl -o nfsw.txt
    curl -L https://big.oisd.nl -o big.txt
    curl -L https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-social/hosts -o stock.txt
    echo Done!
}

while getopts ":uhgc:" o; do
    case "${o}" in
        h)
            help
            exit;;
        g)
            get
            exit;;
        u)
            update
            exit;;
        c)
            create "${OPTARG}"
            exit;;
        \?)
            echo "Error: Invalid option"
            exit;;
    esac
done