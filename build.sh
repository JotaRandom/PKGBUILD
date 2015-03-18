#!/usr/bin/bash

for i in $HOME/Proyectos/Jristz/pkgbuild/*
do
	cd "$i"
	makepkg -sc -d --nobuild -e --verifysource
	cd $HOME/Proyectos/Jristz/pkgbuild
	
done
