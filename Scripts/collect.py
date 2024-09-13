import definitions as d
import unified
import shutil, os

def main():
    files_to_copy = d.generate_list()
    for path in d.FORKS:
        os.chdir(d.FORKS[path])
        for root, dir, files in os.walk(path):
            for file in files:
                if file in files_to_copy:
                    path = os.path.abspath(file)
                    des = os.path.join(d.BLOCK_LIST_PATH, os.path.basename(file))
                    shutil.copyfile(path, des)
    unified.main(d.ROOT_DIR, d.BLOCK_LIST_PATH)      
    
            
            
if __name__ == "__main__":
    main()