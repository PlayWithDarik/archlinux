#!/bin/bash

# Arch Linux Fast Install - Быстрая установка Arch Linux

loadkeys ru
setfont cyr-sun16

echo 'Синхронизация системных часов'
timedatectl set-ntp true

echo 'Создание разделов'
(
  echo o;

  echo n;
  echo;
  echo;
  echo;
  echo +512M;

  echo n;
  echo;
  echo;
  echo;
  echo +8G;

  echo n;
  echo;
  echo;
  echo;
  echo +8192M;

  echo n;
  echo p;
  echo;
  echo;
  echo a;
  echo 1;

  echo w;
) | fdisk /dev/sda

echo 'Ваша разметка диска'
fdisk -l

echo 'Форматирование дисков'
mkfs.ext2  /dev/sda1 -L boot
mkfs.ext4  /dev/sda2 -L root
mkswap /dev/sda3 -L swap
mkfs.ext4  /dev/sda4 -L home

echo 'Монтирование дисков'
mount /dev/sda2 /mnt
mkdir /mnt/{boot,home}
mount /dev/sda1 /mnt/boot
swapon /dev/sda3
mount /dev/sda4 /mnt/home

echo 'Выбор зеркал для загрузки.'
read -p "1 - archlinux.ip-connect.vn.ua, 2 - mirohost.net, 3 - nix.org.ua:" mirrors_setting
if   [[ $mirrors_setting == 1 ]]; then
  echo "Server = http://archlinux.ip-connect.vn.ua/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
elif [[ $mirrors_setting == 2 ]]; then
  echo "Server = http://mirror.mirohost.net/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
elif [[ $mirrors_setting == 3 ]]; then
  echo "Server = http://mirrors.nix.org.ua/linux/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
fi

echo 'Установка основных пакетов'
pacstrap /mnt base base-devel linux linux-firmware nano dhcpcd netctl

echo 'Настройка системы'
genfstab -pU /mnt >> /mnt/etc/fstab

arch-chroot /mnt sh -c "$(curl -fsSL git.io/JtvPw)"
