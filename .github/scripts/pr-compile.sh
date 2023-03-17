#!/bin/bash
set -e

PR_NUMBER=${1}
LANGUAGE=${2}
# to stop recompiling all queries if multiple files are modified
LIBRARY_SCANNED=false

for file in $(gh pr view $PR_NUMBER --json files --jq '.files.[].path'); do
    # if the file is a query file .ql or .qll
    if [[ $file == *.ql ]]; then
        echo "[+] Compiling $file (in $LANGUAGE)"
        # compile the query
        gh codeql query compile  \
            --threads=0 --check-only \
            --warnings=error \
            --search-path=./codeql --additional-packs=./codeql \
            ./$file

    # if github folder is modified
    elif [[ $file == $LANGUAGE/github/* ]] && [[ $LIBRARY_SCANNED == false ]]; then
        echo "[+] Libray changed, compiling all queries in $LANGUAGE"
        gh codeql query compile \
            --threads=0 --check-only \
            --warnings=error \
            --search-path=./codeql --additional-packs=./codeql \
            ./$LANGUAGE/
        # set LIBRARY_SCANNED to true to prevent recompiling
        LIBRARY_SCANNED=true

    fi
done

echo "[+] Complete"
