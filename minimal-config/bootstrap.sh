set -e

rootpath="https://raw.githubusercontent.com/sharkdp/config-files/master/minimal-config"

files=".vimrc .bashrc .alias"

bd="$HOME/.backup-config-files"
if [ -e "$bd" ]; then
    echo -n "Delete old backup in '$bd' (Ctrl-C to cancel)?"
    read
    rm -r "${bd}"
fi
mkdir "${bd}"

for file in $files; do
    path="$HOME/$file"
    echo "Backing up and $file"
    if [[ -e "$path" ]]; then
        cp -v "$path" "${bd}/$file"
    fi
    echo "Downloading minimal $file"
    wget -q --no-check-certificate -O "$path" "${rootpath}/$file"
done
