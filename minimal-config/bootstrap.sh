set -e

rootpath="https://raw.githubusercontent.com/sharkdp/config-files/master/minimal-config"

files=".vimrc .bashrc .alias"

bd="$HOME/.backup-config-files"
mkdir "${bd}"

for file in $files; do
    path="$HOME/$file"
    echo "Backing up and downloading new $file"
    cp -v "$path" "${bd}/$file"
    wget -q --no-check-certificate -O "$path" "${rootpath}/$file"
done
