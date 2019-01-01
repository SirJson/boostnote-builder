#!/bin/bash

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.


printf "\nBoostnote Builder v3 for master_git\n"
printf "─────────────────────\n\n"
printf "This script is based on the AUR files made by rokt33r (thank you!)\n\n"
printf "I made the following process changes:\n"
printf "\t* I've built a new patch for removing analytics in v0.11.10.\n"
printf "\t* I'm creating a normal electron app. No starter script needed.\n"
printf "\t* I didn't include the warnings fix because I think it might break the app.\n"
printf "\t* This script will create a \"User only\" build in your home directory.\n"
printf "\t* It should run on almost every mainstream distro. (No guarantees!)\n\n"
printf "If the dependency warnings scare you write a ticket upstream!\n\n"
printf "> https://github.com/BoostIO/Boostnote/issues\n\n"
printf "─────────────────────\n\n"

read -p "Press any key to start..."

BASE="$PWD"
REPO="https://github.com/BoostIO/Boostnote.git"
BUILD_FILES="$PWD/boostnote.git"
LOCAL_LIB="$HOME/.local/lib"
LOCAL_BIN="$HOME/.local/bin"
LOCAL_SHARE="$HOME/.local/share"
ICONA_DIR="$LOCAL_SHARE/icons/hicolor/128x128"
ICONB_DIR="$LOCAL_SHARE/icons/hicolor/48x48"
ICONC_DIR="$LOCAL_SHARE/icons/hicolor/16x16"
APP_DIR="$LOCAL_SHARE/applications"
ENTRY_EXEC_VAL="Exec=$HOME/.local/bin/boostnote %U"
NODEPKG_CMD=""
NODEPKG_TYPE=0

function panic() # in the Disco
{
    echo $1
    exit 1
}

function select_node_pkgmgr()
{
    command -v "yarn" &> /dev/null
    test $? -eq 0 && NODEPKG_CMD="yarn" && NODEPKG_TYPE=2 && echo "Using Yarn..." && return 0
    command -v "yarnpkg" &> /dev/null
    test $? -eq 0 && NODEPKG_CMD="yarnpkg" && NODEPKG_TYPE=3 && echo "Using Yarn (old version)..." && return 0
    command -v "npm" &> /dev/null
    test $? -eq 0 && NODEPKG_CMD="npm" && NODEPKG_TYPE=1 && echo "Using NPM..." && return 0
    return 1
}

function install_grunt()
{
    echo "I couldn't find grunt-cli on your system. Do you want to install it? You might need to have sudo rights or be root."
    read -r -p "Continue? [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY])
            if [ $NODEPKG_TYPE -eq 0 ]; then
                sudo $NODEPKG_CMD install -g grunt-cli
            else
                $NODEPKG_CMD global add grunt-cli
            fi
            ;;
        *)
            panic "I can't build without grunt. Goodbye!"
            ;;
    esac
}


if [ -d "$BUILD_FILES" ]; then # Cleanup...
    rm -rf "$BUILD_FILES"
fi

echo "Checking if Node.js is installed..."
command -v "node" || panic "Failed to find Node.js on your system. Install Node.js and try again!"

echo "Selecting a node package manager..."
select_node_pkgmgr || panic "Failed to find npm, yarn or yarnpkg! Can't continue without a package manager."

echo "Checking if grunt is installed..."
command -v "grunt" || install_grunt

echo "Cloning repository..."
git clone --branch master --single-branch "$REPO" "$BUILD_FILES"
cd "$BUILD_FILES"

echo "Install dependencies..."
printf "> If you worry about the warnings please open a ticket here: https://github.com/BoostIO/Boostnote/issues\n\n"
$NODEPKG_CMD install

echo "Compile..."
grunt compile

echo "Build and package..."
grunt pack:linux

if [ -d "$LOCAL_LIB/Boostnote-linux-x64" ]; then # More cleanup...
    echo "Updating application for $USER..."
    rm -rf "$LOCAL_LIB/Boostnote-linux-x64"
else
    echo "Installing application for $USER..."
fi

# Don't worry with the -p parameter we not only create the full tree we also ignore folders that already exist
mkdir -p "$LOCAL_LIB"
mkdir -p "$LOCAL_BIN"
mkdir -p "$LOCAL_SHARE"
mkdir -p "$ICONA_DIR"
mkdir -p "$ICONB_DIR"
mkdir -p "$ICONC_DIR"
mkdir -p "$APP_DIR"

mv dist/Boostnote-linux-x64 "$LOCAL_LIB"
ln -sf "$LOCAL_LIB/Boostnote-linux-x64/Boostnote" "$LOCAL_BIN/boostnote"

echo "Creating start menu entry..."
cd "$BASE"

if [ -f "$BASE/boostnote.desktop" ]; then
    rm -f "$BASE/boostnote.desktop"
fi

cp "$BASE/boostnote.desktop" "$APP_DIR"
echo $ENTRY_EXEC_VAL >> "$APP_DIR/boostnote.desktop"
cp -u "$BASE/icon128.png" "$ICONA_DIR/icon128.png"
cp -u "$BASE/icon48.png" "$ICONB_DIR/icon48.png"
cp -u "$BASE/icon16.png" "$ICONC_DIR/icon16.png"

echo "Updating desktop database..."
update-desktop-database
printf "─────────────────────\n\n"
printf "> Boostnote successfully installed! <\n\n"
printf "> Make sure that $LOCAL_BIN is in your path otherwise your system won't find the binary\n\n"
