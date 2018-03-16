## zippyshare.sh
### bash script for downloading zippyshare files. Updated to 2018-03-16

##### Download single file from zippyshare

    sh zippyshare.sh url

##### Batch-download files from URL list:

    sh zippyshare.sh url-list.txt     # url-list.txt must contain one zippyshare.com url per line

Example:

    sh zippyshare.sh http://www12.zippyshare.com/v/3456789/file.html  

zippyshare.sh uses `wget` with the `--continue` flag, which skips over completed files and attempts to  resume partially downloaded files.

### Requirements: `coreutils`, `grep`, `sed`, `awk`, `perl`, **`wget`**

