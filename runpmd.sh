#!/bin/bash

# Wrapper script to run PMD with apex parameters"
# Assumes vscode & pmd extension is installed in the user home directory"
# Output is one or more html files formatted using xslt"
# 
# Usage:"
#     runpmd.sh -i source - o output_dir [-d]"
# 
#       -i: the input may be eiher a specific file or a directory"
#       -o: the directory where you want the reports to be written (default is ~/Downloads)"
#       -d: Option: if the source is a directory, generate a detail report for each file "
#           Default is bulk report for all the files in the directory."


BASE_DIR=~/.vscode/extensions/chuckjonas.apex-pmd-0.5.0
EXEC_DIR="${BASE_DIR}"/bin/pmd/bin/
RULE_DIR="${BASE_DIR}"/rulesets/apex_ruleset.xml

source=
output_dir=~/Downloads
detail=
filename=output.html
rundate=$(date +"%Y%M%d%H%M")

usage() {
    echo ""
    echo ""
    echo "Wrapper script to run PMD with apex parameters"
    echo "Assumes vscode & pmd extension is installed in the user home directory"
    echo "Output is one or more html files formatted using xslt"
    echo ""
    echo "Usage:"
    echo "    runpmd.sh -i source - o output_dir [-d]"
    echo ""
    echo "       -i: the input may be eiher a specific file or a directory"
    echo "       -o: the directory where you want the reports to be written (default is ~/Downloads)"
    echo "       -d: Option: if the source is a directory, generate a detail report for each file "
    echo "           Default is bulk report for all the files in the directory."
    echo ""
}

genReport() {
    cd "${EXEC_DIR}"
    ./run.sh pmd -f xslt -l apex -R "${RULE_DIR}"  -d "${source}" > "${output_dir}"/"${filename}"
}


if [ $# == 0 ]; then
    usage
    exit 1
fi

while [ "$1" != "" ]; do
    case $1 in
        -i )    shift
                source=$1
                ;;
        -o )    shift
                output_dir=$1
                ;;
        -d )    detail=1
                ;;
    esac
    shift
done


if [ -d "${source}" ]; then
  if [ $detail  ]; then
    # get the individual files and create the report
    source_dir=$source
    for f in "${source_dir}"/*.cls
    do
        filename=$(basename "${f}" .cls)'-'${rundate}.html
        source="${f}"
        genReport
    done
  else  # detail not set
    filename='PMD-'${rundate}.html
    genReport
  fi
elif [ -f "${source}" ]; then
    filename=$(basename "${source}" .cls)'-'${rundate}.html
    genReport
else
    echo ""
    echo ""
    echo "No input source specified"
    usage
    exit 1
fi
