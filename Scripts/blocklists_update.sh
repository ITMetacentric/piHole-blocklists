#!/bin/bash

ROOTDIR=/home/isaac/blocklists
PIHOLE=$ROOTDIR/piHole_blocklist
LIST=/home/isaac/blocklists/Lists
YOUTUBE=/home/isaac/blocklists/youTube_ads_4_pi-hole

UPSTREAMS=("https://github.com/blocklistproject/Lists.git" "https://github.com/kboghdady/youTube_ads_4_pi-hole.git")
UPSTREAM_DIRS=("$LIST" "$YOUTUBE")
DIRECTORIES=("$PIHOLE" "$LIST" "$YOUTUBE")

help()
{
    echo "A bash script to create the pihole blocklists"
    echo
    echo "Syntax: scriptTemplate [-u|h|c|A]"
    echo "options:"
    echo
    echo "h     Print this Help."
    echo "u     Clone and/or update the forks"
    echo "c     Create the unified lists, takes file for lists as argument"
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

update()
{
    echo "$ROOTDIR"
    cd "$ROOTDIR" || exit
    for dir in "${DIRECTORIES[@]}";
    do 
        if [ -d "$dir" ]; then
            echo "$dir exists, not cloning"
        else
            name=${dir##*/}
            git clone "git@github.com:ITMetacentric/$name.git"
            wait
        fi
    done
    for i in "${!UPSTREAM_DIRS[@]}"; do
        cd "${UPSTREAM_DIRS[$i]}" || exit
        git remote add upsteam "${UPSTREAMS[$i]}"
        git checkout master
        git fetch upstream
        git merge upstream/master
        cd .. || exit
    done
    echo collecting external large lists
    cd "$LIST" || exit
    curl -L https://nsfw.oisd.nl -o nfsw.txt
    curl -L https://big.oisd.nl -o big.txt
    curl -L https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-social/hosts -o stock.txt
}

while getopts ":uhc:" o; do
    case "${o}" in
        h)
            help
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