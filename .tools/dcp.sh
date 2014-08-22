set -e

downloadDir="$HOME/Downloads"

if [[ $1 == "-h" || $1 == "--help" ]]; then
    echo "Usage: dcp [DEST]"
    echo "Copies the latest download to the directory DEST"
    echo "and unpacks it if it is an archive."
    echo
    echo "If DEST is not given, the file is copied to the"
    echo "current working directory."
    exit 0
fi

dfile=$(ls --sort=time "$downloadDir" | head -n 1)

dpath="$downloadDir/$dfile"

if [[ ! -f $dpath ]]; then
    echo "The latest download '$dfile' is not a file" 1>&2
    exit 1
fi

targetDir="$1"
[[ -z $targetDir ]] && targetDir="$(pwd)"

if [[ ! -d $targetDir ]]; then
    echo "The target directory '$targetDir' does not exist" 1>&2
    exit 1
fi

cp --interactive --verbose "$dpath" "$targetDir"

ext="${dfile##*.}"

if [[ $ext == "zip" || $ext == "rar" || $ext == "gz" || $ext == "tar" ]]; then
    echo
    echo "Press key to unpack '$dfile' and delete the archive? (Ctrl-C to cancel)"

    read

    cd "$targetDir"
    unp -U "$dfile"
    rm "$dfile"
fi
