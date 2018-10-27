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


printf "\nBoostnote Builder for v0.11.10\n"
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
BUILD_FILES="$PWD/boostnote"
LOCAL_LIB="$HOME/.local/lib"
LOCAL_BIN="$HOME/.local/bin"
LOCAL_SHARE="$HOME/.local/share"
ICONA_DIR="$LOCAL_SHARE/icons/hicolor/128x128"
ICONB_DIR="$LOCAL_SHARE/icons/hicolor/48x48"
ICONC_DIR="$LOCAL_SHARE/icons/hicolor/16x16"
APP_DIR="$LOCAL_SHARE/applications"
ENTRY_EXEC_VAL="Exec=$HOME/.local/bin/boostnote %U"

function panic() # in the Disco
{
    echo $1
    exit 1
}

function install_grunt()
{
    echo "I couldn't find grunt-cli on your system. Do you want that I install it for you? Because it's npm you need to have sudo rights or be root."
    read -r -p "Continue? [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            sudo npm install grunt
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

echo "Checking if npm is installed..."
command -v "npm" || panic "Failed to find npm on your system. Install npm and try again!"

echo "Checking if grunt is installed..."
command -v "grunt" || install_grunt

echo "Cloning repository..."
git clone --branch master --single-branch "$REPO" "$BUILD_FILES"
git checkout ff3026686ff7a8c8954d94527dbfb4538c9addcd # Version 1.10

echo "Apply patch..."
cd "$BUILD_FILES"
patch -Np1 -i "${BASE}/remove-analytics_no-pkgs.patch"

echo "Install dependencies..."
printf "> If you worry about the warnings please open a ticket here: https://github.com/BoostIO/Boostnote/issues\n\n"
npm install --no-optional --no-shrinkwrap

echo "Compile..."
grunt compile

echo "Pack..."
grunt pack:linux

echo "Installing application for $USER..."

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

cp "$BASE/boostnote.desktop" "$APP_DIR"
echo $ENTRY_EXEC_VAL >> "$APP_DIR/boostnote.desktop"
cp "$BASE/icon128.png" "$ICONA_DIR/icon128.png"
cp "$BASE/icon48.png" "$ICONB_DIR/icon48.png"
cp "$BASE/icon16.png" "$ICONC_DIR/icon16.png"

echo "Updating desktop database..."
update-desktop-database
printf "─────────────────────\n\n"
printf "> Boostnote successfully installed! <\n\n"
printf "> Make sure that $LOCAL_BIN is in your path otherwise your system won't find the binary\n\n"