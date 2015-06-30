#!/bin/bash


cp ./dist/ctags_lang ~/.ctags
cp .vimrc ~/.vimrc
cp .vimrc.plugins ~/.vimrc.plugins
cp .vimrc.local ~/.vimrc.local
cp .vimrc.plugins.local ~/.vimrc.plugins.local
rm -rf ~/.vim
cp -r vimfiles ~/.vim

# for zzdts
cp zzdts/gitconfig ~/.gitconfig
cp zzdts/tmux.conf ~/.tmux.conf
cp zzdts/desertEx.vim ~/.vim/bundle/ex-colorschemes/colors/desertEx.vim
mkdir -p ~/.vim/bundle/global/plugin/
cp -f zzdts/gtags.vim  ~/.vim/bundle/global/plugin/
