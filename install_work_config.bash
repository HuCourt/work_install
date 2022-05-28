#!/bin/bash

VERBOSE_MODE=0

while getopts "v" OPTION
do
	case $OPTION in
		v) VERBOSE_MODE=1
		;;
	esac
done

function log () {
	if [[ $VERBOSE_MODE -eq 1 ]]; then
	echo "$@"
	fi
}

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
PATH_CUSTOM='org.gnome.settings-daemon.plugins.media-keys'
log "[ADD_KB] Attempting to add custom keybind:"
log "[ADD_KB] name ${KB_NAME}"
log "[ADD_KB] command ${KB_COMMAND}"
log "[ADD_KB] keybind ${KB_BIND}"
# Get list of current custom keybinds
LIST_KB=$(gsettings get ${PATH_CUSTOM} custom-keybindings)
LIST_KB=${LIST_KB#"@as ["}
LIST_KB=${LIST_KB#"["}
LIST_KB=${LIST_KB%"]"}
LIST_KB=$(echo $LIST_KB | tr -d '[:space:]')

contains () {
    [[ $1 =~ (^|',')$2($|',') ]] && return 0 || return 1
}

# Avoid overwriting currents
KEY="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom"
IDX=0
new=""
ADD_NEW_KB=1
while true; do
    new="'"${KEY}${IDX}/"'"
    if contains "${LIST_KB}" "${new}" ;
    then
        kb_get_command="gsettings get ${PATH_CUSTOM}.custom-keybinding:${KEY}${IDX}/"
        EXISTING_NAME=$(${kb_get_command} name)
        if [ "${EXISTING_NAME}" = "'${KB_NAME}'" ] ;
        then
		ADD_NEW_KB=0
		break
        fi
        IDX=$((IDX+1))
    else
        break
    fi
done

if [ ${ADD_NEW_KB} -eq 1 ];
then
	if [ ${IDX} -eq 0 ] ;
	then
	    separator=""
	else
	    separator=","
	fi

	# Add new name in list
	LIST_KB="@as "["$LIST_KB""$separator""$new"]

	# Set new list
	gsettings set "${PATH_CUSTOM}" custom-keybindings "${LIST_KB}"
fi

kb_init_command="gsettings set ${PATH_CUSTOM}.custom-keybinding:${KEY}${IDX}/"
${kb_init_command} name "${KB_NAME}"
${kb_init_command} command "${KB_COMMAND}"
${kb_init_command} binding "${KB_BIND}"
if [ ${ADD_NEW_KB} -eq 0 ] ;
then
	echo "[ADD_KB] Updated keybind ${KB_NAME} at ${KEY}${IDX}"
else
	echo "[ADD_KB] Added keybind ${KB_NAME} at ${KEY}${IDX}"
fi
}

echo "Creating symbolic links ..."
ln -sf $(pwd)/.vimrc ~/.vimrc 
ln -sf $(pwd)/.tmux.conf ~/.tmux.conf
ln -sf $(pwd)/.inputrc ~/.inputrc
ln -sf $(pwd)/OpenTermSetup.bash ~/OpenTermSetup.bash

echo "Installing packages ..."
install_package git
install_package vim
#Terminal multiplexer
install_package tmux
#For bringing to forefront
install_package wmctrl

echo "Installing vim plugins ..."
VIM_PLUGIN_REPO=~/.vim/pack/my-plugins/start/
mkdir -p ${VIM_PLUGIN_REPO}
git clone --depth 1 https://github.com/scrooloose/nerdtree.git "${VIM_PLUGIN_REPO}/nerdtree"
git clone --depth 1 https://github.com/christoomey/vim-tmux-navigator.git "${VIM_PLUGIN_REPO}/vim-tmux-navigator"
git clone --depth 1 https://github.com/mileszs/ack.vim.git "${VIM_PLUGIN_REPO}/ack.vim"

echo "Adding keybinds ..."
add_kb "Bring_browser_ff" "$(pwd)/bring_forefront.sh firefox" "<Control>b"
add_kb "Bring_terminal_ff" "$(pwd)/bring_forefront.sh gnome-terminal-server" "<Control>t"
add_kb "Clear terminal" "$(pwd)/clearterm" "<Control>p"
