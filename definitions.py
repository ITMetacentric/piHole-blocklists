import os

# WARNING!: Don't change these. These are the project dependent paths which ensure that the scripts reach the correct directories. 
ROOT_DIR = os.path.dirname(os.path.abspath(__file__))
BIN_PATH = os.path.join(ROOT_DIR, 'bin')
BLOCK_LIST_PATH = os.path.join(ROOT_DIR, 'Lists', 'blocklists')

# Paths to other files: Please use absolute paths. These can be determined using realpath in linux or navigating to and capturing the cd command in windows like this:

# @echo off
# set REL_PATH=..\..\
# set ABS_PATH=
# rem // Save current directory and change to target directory
# pushd %REL_PATH%
# rem // Save value of CD variable (current directory)
# set ABS_PATH=%CD%
# rem // Restore original directory
# popd
# echo Relative path: %REL_PATH%
# echo Maps to path: %ABS_PATH%

FORKS = {
    'Lists': '/home/isaac/blocklists/Lists',
    'youtube': '/home/isaac/blocklists/youTube_ads_4_pi-hole'
}

# Change these to what you want to include

INCLUDE = {
    'abuse': True,
    'ads': True,
    'basic': True,
    'blocklist-vpn': True,
    'crowed_list': True,
    'crypto': True,
    'drugs': True,
    'fortnite': True,
    'fraud': True,
    'gambling': True,
    'malware': True,
    'phishing': True,
    'piracy': True,
    'porn': True,
    'ransomware': True,
    'redirect': True,
    'scam': True,
    'smart-tv': True,
    'tiktok': True,
    'torrent': True,
    'tracking': True,
    'vaping': True,
    'youtube': True,
}


def generate_list():
    return_list = []
    for key, value in INCLUDE.items():
        if value == True:
            return_list.append(f'{key}.txt')
    return return_list