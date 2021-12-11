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
  echo +85G;

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

echo 'Зеркала для загрузки.'
cat > /etc/pacman.d/mirrorlist <<EOF
##
## Arch Linux repository mirrorlist
## Generated on 2021-11-06
##

## Ukraine
Server = https://archlinux.astra.in.ua/\$repo/os/\$arch
Server = https://repo.endpoint.ml/archlinux/\$repo/os/\$arch
Server = https://archlinux.ip-connect.vn.ua/\$repo/os/\$arch
Server = https://mirror.mirohost.net/archlinux/\$repo/os/\$arch
Server = https://mirrors.nix.org.ua/linux/archlinux/\$repo/os/\$arch
EOF

echo 'Установка основных пакетов'
pacstrap /mnt base base-devel linux-zen linux-zen-headers linux-firmware nano dhcpcd netctl dbus e2fsprogs

echo 'Настройка системы'
genfstab -pU /mnt >> /mnt/etc/fstab

arch-chroot /mnt sh -c "$(curl -fsSL git.io/JtvPw)"
