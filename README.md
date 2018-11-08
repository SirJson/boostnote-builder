# Boostnote Builder

Just a little bash script based on the [AUR files made by rokt33r](https://aur.archlinux.org/packages/boostnote/) that builds and installs Boostnote for you.

This should have been a gist but you don't want to trust huge blobs of base64 in a shell script do you?

## Why are you doing this?

Because Boostnote isn't kind enough to just package the plain Electron app into  an archive container so you could try to run it with the distro of your choice. With this script you might have the choice now.

I'm also writing this document in a Boostnote Version made by this script to verify that I didn't break something. ;-)

## Did you change something?
> Also known as why isn't this just a gist??

I made the following build and install process changes:
* I've built a new patch that removes analytics in v0.11.10.
* I'm creating a normal Electron app with this script. No starter script needed.
* I didn't include the warnings fix because I think it might break the app.
* This script will create a \"User only\" build in your home directory.
* It should run now on almost every mainstream distro. (No guarantees!)

## OK how do I run this?

Because we are building something here you need dependencies. Because I didn't want to tie it to one distribution you have to install some Tools on your own if you not already have them.

### Dependencies
* Node.js
* NPM
* Git
* grunt-cli (Can be installed by the script)

I've tested it with [Node.js v8.12.0 LTS](https://nodejs.org/en/blog/release/v8.12.0/). It might work with the latest version as well but if you are in doubt choose the LTS version.

### What now?

Just run install.sh. No sudo or root. You only need the sudo password later if you don't have `grunt-cli` and want the script to install it for you.

And that's it! I hope this script works for you.
