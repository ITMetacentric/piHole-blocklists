import os, mimetypes, urllib
import urllib.request
import pandas as pd
from tqdm import tqdm 
dir = os.getcwd()

dns_entries = []
dns_entries_dedup = []
tqdm.pandas()

# Deduplicate and per new file
def dedup(raw_list):
    print("Deduplicating...")
    df = pd.DataFrame({'col': raw_list})
    df.drop_duplicates(inplace = True)
    dns_entries_dedup = df['col'].tolist()

# collect the oisd_big_abp list
for line in urllib.request.urlopen('https://nsfw.oisd.nl'):
    dns_entries.append(line.decode('utf-8'))
print('Big list collected')

# collect the oisd_nsfw_abp list
for line in urllib.request.urlopen('https://nsfw.oisd.nl'):
    dns_entries.append(line.decode('utf-8'))
print('NSFW List collected')

# Collect contents of every file found
for root, dirs, files in os.walk(dir):
    for file in tqdm.tqdm(files):
        if mimetypes.guess_type(file)[0] == 'text/plain':
            file_path = os.path.join(root, file)
            with open(file_path, 'r') as f:
                file_contents = f.readlines()
                f.close()
            dns_entries.append(file_contents)
        
# uses list comprehension to remove duplicates from the list
print(f'[INFO]: Total Domains: {len(dns_entries_dedup)}')

# Creating file
print("Writing out dedup-list.txt")
with open(os.path.join(dir, 'dedup-list.txt'), 'w') as f:
    for l in tqdm.tqdm(dns_entries_dedup):
        f.writelines(l)
