import os, mimetypes, urllib
import urllib.request
import pandas as pd
from tqdm import tqdm 
dir = os.getcwd()

dns_entries = []
tqdm.pandas()

def split_list(list, num_of_lists):
    chunk_size = int(len(list)/num_of_lists)
    for i in range(0, len(list), chunk_size):
        yield list[i:i + chunk_size]

# Deduplicate and per new file
def dedup(raw_list):
    dns_entries_dedup = []
    print("Deduplicating...")
    df = pd.DataFrame({'col': raw_list})
    df.drop_duplicates(inplace = True)
    dns_entries_dedup = df['col'].tolist()
    return dns_entries_dedup

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
    for file in tqdm(files):
        if mimetypes.guess_type(file)[0] == 'text/plain':
            file_path = os.path.join(root, file)
            with open(file_path, 'r') as f:
                file_contents = f.readlines()
                f.close()
            print(type(file_contents))
            for i in file_contents:
                dns_entries.append(i)
        
# uses list comprehension to remove duplicates from the list
dns_entries_dedup = dedup(dns_entries)
print(f'[INFO]: Total Domains: {len(dns_entries_dedup)}')

files = list(split_list(dns_entries_dedup, 5))
# Creating file
for i in files:
    num = files.index(i)
    print(len(i))
    print(type(i))
    print(f"Writing out dedup-list-{num}.txt")
    with open(os.path.join(dir, f'dedup-list{num}.txt'), 'w') as f:
        f.writelines(i)