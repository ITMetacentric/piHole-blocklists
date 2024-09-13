#!/bin/bash

ROOTDIR=/home/isaac/blocklists
PIHOLE=$ROOTDIR/piHole-blocklists
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
    echo "a     Complete u then c"
    echo 
}

create( )
{
    if [ -z "$1" ]; then
        echo no agruments passed, adding all lists
        cp -r $LIST $PIHOLE
        wait
        cp "$YOUTUBE/youtube.txt" "$PIHOLE/Lists"
        wait
    else
        echo reading files...
        while IFS= read -r line; do
            files+=$line
        done < "$1"
        echo copying files...
        for file in "${files[@]}";
        do
            cp "$YOUTUBE/youtube.txt" "$PIHOLE/Lists"
            cp "$LIST/$file" "$PIHOLE/Lists"
        done
        echo combinding files and spliting into deduplicated file...
        cd "$PIHOLE/Lists" || exit
        find . -name "*.txt" -type f -print0 | xargs -0 -n 1 -P 4 sed -i -e '$a\'
        wait
        echo *.txt | xargs -P 4 cat > temp.txt
        wait
        cd "$PIHOLE/bin" || exit
        split -l 400000 "$PIHOLE/Lists/temp.txt" dedup
        wait
        cd "$PIHOLE/Lists" || exit
        echo removing temp file
        rm temp.txt
    fi
}

update()
{
    for dir in "${DIRECTORIES[@]}";
    do 
        if [ ! -d "$dir" ]; then
            name=${dir##*/}
            git clone "https://github.com/ITMetacentric/$name.git"
            wait
        else
            echo "$dir exists, not cloning"
        fi
    done
    for i in "${!UPSTREAM_DIRS[@]}"; do
        cd "${UPSTREAM_DIRS[$i]}" || exit
        git remote add upsteam "${UPSTREAMS[$i]}"
        wait
        git checkout master
        wait
        git fetch upstream
        wait
        git merge upstream/master
        wait 
        cd .. || exit
    done
    echo collecting external large lists
    cd "$LIST" || exit
    curl -L https://nsfw.oisd.nl -o nfsw.txt
    wait
    curl -L https://big.oisd.nl -o big.txt
    wait
}

all()
{
    update
    wait
    create "$1"
}

while getopts ":uhca:" option; do
    case $option in
        h)
            help
            exit;;
        u)
            update
            exit;;
        c)
            create "$OPTARG"
            exit;;

        a)
            all "$OPTARG"
            exit;;
        \?)
            echo "Error: Invalid option"
            exit;;
    esac
done