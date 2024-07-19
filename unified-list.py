import os
dir = os.getcwd()

dns_entries = []

# Collect contents of every file found
for root, dirs, files in os.walk(dir):
    for file in files:
        file_path = os.path.join(root, file)
        with open(file_path, 'r') as f:
            file_contents = f.readlines()
            f.close()
        dns_entries.append(file_contents)

# Removing duplicates by converting to dictionary and back again
dns_entries = list(dict.fromkeys(dns_entries)) # converts to dict and then back to list but deduplicated

# Creating file
with open(os.path.join(dir, 'dedup-list.txt'), 'w') as f:
    for l in dns_entries:
        f.writelines(l)
