#!/bin/bash

git clone https://github.com/HuCourt/work_install.git
cd work_install
ln -s $(pwd)/.vimrc ~/.vimrc 
ln -s $(pwd)/.tmux.conf ~/.tmux.conf

mkdir ~/.vim
mkdir ~/.vim/autoload
mkdir ~/.vim/bundle
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
git clone https://github.com/scrooloose/nerdtree.git ~/.vim/bundle/nerdtree


