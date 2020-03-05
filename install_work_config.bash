#!/bin/bash

install_package() {
PKG_INSTALLED=$(dpkg-query -W --showformat='${Status}\n' "$1" | grep "install ok installed")
if [ "$PKG_INSTALLED" == "" ];
then
    echo "$1 not found. Installing ..."
    sudo apt-get --yes install "$1";
fi
}

add_kb() {
#Add keybinding to ubuntu
KB_NAME=$1
KB_COMMAND=$2
KB_BIND=$3

LIST_KB=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)
LIST_KB=${LIST_KB#"@as ["}
LIST_KB=${LIST_KB#"["}
LIST_KB=${LIST_KB%"]"}
LIST_KB=$(echo $LIST_KB | tr -d '[:space:]')

contains () {
    [[ $1 =~ (^|',')$2($|',') ]] && return 0 || return 1
}

KEY="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom"
IDX=0
new=""
while true; do
    new="'"${KEY}${IDX}/"'"
    
    if contains "${LIST_KB}" "${new}" ;
    then
        IDX=$((IDX+1))
    else
        break
    fi
done
if [ ${IDX} -eq 0 ] ;
then
    separator=""
else
    separator=","
fi
    
LIST_KB="@as "["$LIST_KB""$separator""$new"]

kb_init_command="gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${IDX}/"

gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "${LIST_KB}"
${kb_init_command} name "${KB_NAME}"
${kb_init_command} command "${KB_COMMAND}"
${kb_init_command} binding "${KB_BIND}"

}
ln -sf $(pwd)/.vimrc ~/.vimrc 
ln -sf $(pwd)/.tmux.conf ~/.tmux.conf

install_package git
#For auto complete me
install_package python3-dev
install_package vim
#Terminal multiplexer
install_package tmux
#For bringing to forefront
install_package wmctrl
#For formatting
install_package clang-format

mkdir -p ~/.vim/autoload
mkdir -p ~/.vim/bundle
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
git clone https://github.com/scrooloose/nerdtree.git ~/.vim/bundle/nerdtree
git clone https://github.com/christoomey/vim-tmux-navigator.git ~/.vim/bundle/vim-tmux-navigator
git clone https://github.com/Valloric/YouCompleteMe.git ~/.vim/bundle/YouCompleteMe
git clone https://github.com/Chiel92/vim-autoformat.git ~/.vim/bundle/vim-autoformat

(
    cd ~/.vim/bundle/YouCompleteMe
    git submodule update --init --recursive
    python3 install.py
)

add_kb "Bring_browser_ff" "$(pwd)/bring_forefront.sh firefox" "<Control>b"
add_kb "Bring_terminal_ff" "$(pwd)/bring_forefront.sh gnome-terminal-server" "<Control>t"
