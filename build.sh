#!/usr/bin/bash

for i in "$HOME/Proyectos/jristz/pkgbuild/"*
do
	cd "$i"
	makepkg -sc -d --nobuild -e --verifysource
	cd "$HOME/Proyectos/jristz/pkgbuild"
	
done
