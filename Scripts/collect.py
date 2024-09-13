from definitions import generate_list, FORKS, BIN_PATH, BLOCK_LIST_PATH, ROOT_DIR
import unified
import shutil, os

def main():
    files_to_copy = generate_list()
    for path in FORKS:
        os.chdir(FORKS[path])
        for root, dir, files in os.walk(path):
            for file in files:
                if file in files_to_copy:
                    path = os.path.abspath(file)
                    des = os.path.join(BLOCK_LIST_PATH, os.path.basename(file))
                    shutil.copyfile(path, des)
    unified.main(ROOT_DIR, BLOCK_LIST_PATH)      
    
            
            
if __name__ == "__main__":
    main()