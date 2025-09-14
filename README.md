# Usage
## Add prefix "new-" to all files
```bash
mf -a "new-"
file1.txt   -> new-file1.txt
file2.txt   -> new-file2.txt
```


## Remove substring "old-" from all files
```bash
mf -r "old-"
old-file1.txt -> file1.txt
old-file2.txt -> file2.txt
```


## Combine: remove "old-" and add "test-" in one go
```bash
mf -a "test-" -r "old-"
old-file1.txt -> test-file1.txt
old-file2.txt -> test-file2.txt
```
____


# TODO

- ~~adding new name to all files~~
- ~~remove specific name in all files~~
- option transform to lowercase
- option change filename that have spaces to (-) or (_) 
- distribution across os
