#!/usr/bin/bash

for i in $HOME/Proyectos/Jristz/PKGBUILD/*
do
	cd "$i"
	makepkg -sc -d --nobuild -e --verifysource
	cd $HOME/Proyectos/Jristz/PKGBUILD
	
done
