export reset='\x1b[0m'
export blue='\x1b[34;01m'
export turquoise='\x1b[36;01m'
export darkgreen='\x1b[32;06m'
export bold='\x1b[01m'
export brown='\x1b[33;06m'
export purple='\x1b[35;06m'
export fuscia='\x1b[35;01m'
export yellow='\x1b[33;01m'
export darkblue='\x1b[34;06m'
export green='\x1b[32;01m'
export darkred='\x1b[31;06m'
export teal='\x1b[36;06m'
export red='\x1b[31;01m'

export PATH="${PATH}:/usr/sbin/:/opt/maple10/bin/"
export EDITOR="/usr/bin/vim"

include="/etc/profile.d/bash-completion"
include="$include ${HOME}/.alias"

for inc in $include
do
    [ -f $inc ] && source $inc
done

eval `dircolors -b ~/.dir_colors`

wb () {
    if [ -z "$1" ]; then
        echo -ne "${blue}wb${reset}> $red"
        while read line
        do
            echo -e "${reset}"
            wb "$line"
            echo -ne "${blue}wb${reset}> $red"
        done
        echo
        return
    fi
    tmp="/home/shark/.wb.tmp"
    if [ "$1" != "-a" ]
    then
        words="\\<$@\\>"
    else
        shift
        words=$@
    fi
    grep -i --color "${words}" ~shark/de-en | sed \
        -e 's/^/'${darkblue}'/' \
        -e 's/::/'$reset'->'${darkgreen}'/' \
        -e 's/$/'${reset}'/' > $tmp
    nr=`wc -l $tmp | awk '{ print $1 }'`
    if [ $nr -lt 1 ]; then
        echo -e "${bold}grep returned no results, trying agrep${reset}"
        for i in `seq 1 8`; do
            echo -e "${bold}agrep -$i${reset}"
            agrep -i -$i "${words}" ~shark/de-en > $tmp
            nr=`wc -l $tmp | awk '{ print $1 }'`
            if [ $nr -gt 0 ]; then
                cat $tmp | sed \
                    -e 's/^/'${darkblue}'/' \
                    -e 's/::/'$reset'->'${darkgreen}'/' \
                    -e 's/$/'${reset}'/'
                rm $tmp
                return
            fi
        done
    else
        cat $tmp
        rm $tmp
    fi
}

rehash () {
    . ~/.bashrc 2> /dev/null
}

PS1="\[\033[1;34m\]\u\[\033[0m\] (\w) $ "

case ${TERM} in
    xterm*|rxvt|Eterm|eterm)
        PS1="${PS1}\[\e]0;\w\a\]"
        ;;
esac


export HISTCONTROL="ignoredups"
export HISTFILESIZE="1000"


shopt -s checkwinsize

export GTK2_RC_FILES=$HOME/.gtkrc-2.0

if [ -f /etc/bash_completion ]; then
 . /etc/bash_completion
fi


geounp() {
    unp $1
    rm ${1/.zip/-wpts.gpx} $1
    mv ${1/.zip/.gpx} $2.gpx
}


cd /home/shark

export PATH="$PATH:/home/shark/Informatik/java/android-sdk-linux/platform-tools/"

nwlook() {
#avahi-browse -t -a | grep --color=never IPv4 | grep mvagusta
    avahi-browse -t -a | grep --color=never IPv4
}

remotenwlook() {
    ssh peter@sultan.theo3.physik.uni-stuttgart.de 'avahi-browse -t -a | grep --color=never IPv4 | grep -v mvagusta;avahi-browse -t -a  | grep --color=never IPv4 | grep mvagusta'
}

pdfFontToOutlines() {
    gs -sDEVICE=pswrite -dNOCACHE -sOutputFile=- -q -dbatch -dNOPAUSE -dQUIET "$1" -c quit | ps2pdf - "$2"
}

notify() {
    /home/shark/.nwlook/notify.sh &
}

cleanLatexFolder() {
    for file in *.aux *.toc *.blg *.bbl *.synctex.gz *.dvi *.fdb_latexmk *.out *.ps *Notes.bib *.log; do
       if [ -e "$file" ]; then
            echo -n "Delete '$file' [y]: "
            read answ
            if [ x"$answ" == x"y" ] || [ x"$answ" == x"" ]; then
                rm "$file"
            fi
        fi
    done
}


alias git='LC_ALL=en_US git'

# prevent Ctrl-S from freezing the terminal
bind -r '\C-s'
stty -ixon
