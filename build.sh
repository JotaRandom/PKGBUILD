#!/usr/bin/bash

for i in "$HOME/Público/PKGBUILD/"*
do
	yay -G "$i"
#	cd "$i"
#	makepkg -sc -d --nobuild -e --verifysource
	cd "$HOME/Público/PKGBUILD/"
	
done
