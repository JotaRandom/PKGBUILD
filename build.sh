#!/usr/bin/bash

# Ensure curl is available
if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl is required but not installed. Please install curl and rerun the script."
    exit 1
fi

# Change to the target directory
cd "$HOME/Público/PKGBUILD/" || {
    echo "Error: Could not change to $HOME/Público/PKGBUILD/"
    exit 1
}

# Process each item in the directory
for i in *; do
    # Skip build.sh and README.md
    if [ "$i" = "build.sh" ] || [ "$i" = "README.md" ]; then
        echo "Skipping: $i (reserved file)"
        continue
    fi

    echo "Processing directory: $i"

    # Skip if not a directory or symbolic link
    if [ ! -d "$i" ] && [ ! -L "$i" ]; then
        echo "  Skipping: $i is not a directory or symbolic link"
        continue
    fi

    # Handle symbolic links
    if [ -L "$i" ]; then
        if [ ! -e "$i" ]; then
            echo "  Removing broken symbolic link: $i"
            rm "$i"
        else
            echo "  Skipping: $i is a valid symbolic link"
            continue
        fi
    fi

    # Check if the package exists on AUR via HTTP status
    page_url="https://aur.archlinux.org/packages/$i/"
    echo "  Checking AUR package page: $page_url"
    status=$(curl -s -o /dev/null -w "%{http_code}" "$page_url")
    if [ "$status" != "200" ]; then
        echo "  Package $i does not exist on AUR (HTTP $status), cleaning up local if present"
        if git submodule status "$i" >/dev/null 2>&1; then
            echo "  Removing existing submodule $i"
            git submodule deinit -f "$i" >/dev/null 2>&1
            git rm -f "$i" >/dev/null 2>&1
            rm -rf ".git/modules/$i"
        fi
        rm -rf "$i"
        continue
    fi
    echo "  Package $i exists on AUR (HTTP 200), proceeding"

    # Check if the directory is already a submodule
    if git submodule status "$i" >/dev/null 2>&1; then
        echo "  $i is already a submodule, updating..."
        git submodule update --init --remote "$i"
        if [ $? -eq 0 ]; then
            git add "$i"
            echo "  Submodule $i updated successfully"
        else
            echo "  Warning: Failed to update submodule $i"
        fi
        continue
    fi

    # Remove any existing git cache for the directory
    echo "  Preparing to process $i as a new submodule"
    git rm -r --cached "$i" >/dev/null 2>&1
    rm -rf "$i"

    # Attempt to clone the repository to a temporary directory
    url="ssh://aur@aur.archlinux.org/${i}.git"
    temp=$(mktemp -d)
    echo "  Cloning $url to temporary directory $temp"
    if git clone --quiet "$url" "$temp" 2>/dev/null; then
        # Check if the repository has a valid HEAD and contains files
        if git -C "$temp" rev-parse HEAD >/dev/null 2>&1 && [ -n "$(git -C "$temp" ls-files)" ]; then
            echo "  Repository $i has content, adding as submodule"
            mv "$temp" "$i"
            if git submodule add "$url" "$i" 2>/dev/null; then
                git add "$i"
                echo "  Submodule $i added successfully"
            else
                echo "  Error: Failed to add $i as a submodule"
                rm -rf "$i"
            fi
        else
            echo "  Repository $i is empty, removing temporary clone"
            rm -rf "$temp"
        fi
    else
        echo "  Warning: Failed to clone $url (possible network issue), skipping $i"
        rm -rf "$temp"
    fi
done
