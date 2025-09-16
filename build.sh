#!/usr/bin/bash

cd "$HOME/Público/PKGBUILD/" || exit 1

for i in *; do
    if [ ! -d "$i" ] && [ ! -L "$i" ]; then
        continue
    fi

    if [ -L "$i" ]; then
        if [ ! -e "$i" ]; then
            rm "$i"
        else
            continue
        fi
    fi

    need_to_rm_local=false
    if [ -d "$i" ]; then
        if git submodule status "$i" >/dev/null 2>&1; then
            git submodule update --init --remote "$i"
            git add "$i"
            continue
        else
            need_to_rm_local=true
            git rm -r --cached "$i" >/dev/null 2>&1
        fi
    fi

    url="ssh://aur@aur.archlinux.org/${i}.git"
    temp=$(mktemp -d)
    if git clone --quiet "$url" "$temp"; then
        if git -C "$temp" rev-parse HEAD >/dev/null 2>&1 && [ -n "$(git -C "$temp" ls-files)" ]; then
            if $need_to_rm_local; then
                rm -rf "$i"
            fi
            mv "$temp" "$i"
            git submodule add "$url" "$i"
            git add "$i"
        else
            rm -rf "$temp"
            if $need_to_rm_local; then
                rm -rf "$i"
            fi
        fi
    else
        rm -rf "$temp"
    fi
done
