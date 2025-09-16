#!/usr/bin/bash

for i in "$HOME/Público/PKGBUILD/"*
do

	git rm "$i/"*
	git submodule add ssh://aur@aur.archlinux.org/"$i".git "$i"

	cd "$HOME/Público/PKGBUILD/"
	
done
