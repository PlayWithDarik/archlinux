#!/usr/bin/env bash

echo
echo "INSTALLING AUR SOFTWARE"
echo

cd "${HOME}"

echo "CLOING: YAY"
git clone "https://aur.archlinux.org/yay.git"

cd ${HOME}/yay
makepkg -si

echo
echo "Done!"
echo
