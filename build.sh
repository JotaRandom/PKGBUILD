#!/usr/bin/env bash

for i in $HOME/Proyectos/Jristz/PKGBUILD/*
do
	cd "$i"
	#chown -R ct:users ./*
	#chmod -R 1777 ./*
	makepkg -sc -d --nobuild -e --verifysource
	cd $HOME/Proyectos/Jristz/PKGBUILD
	
done
