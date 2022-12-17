#!/bin/bash

# Arch Linux Fast Install - Быстрая установка Arch Linux

loadkeys ru
setfont cyr-sun16

echo 'Синхронизация системных часов'
timedatectl set-ntp true

echo 'Форматирования диска'
wipefs --all /dev/sda

echo 'Создание разделов'
(
 echo g;

 echo n;
 echo ;
 echo;
 echo +4G;
 echo y;
 
  echo n;
 echo ;
 echo;
 echo;
 echo y;
 echo t;
 echo 1;
  
 echo w;
) | fdisk /dev/sda

echo 'Ваша разметка диска'
fdisk -l

echo 'Форматирование дисков'
mkswap /dev/sda1 
mkfs.btrfs /dev/sda2

echo 'Монтирование дисков'
swapon /dev/sda1
mount /dev/sda2 /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
umount /mnt
mount -o rw,noatime,compress=zstd:3,ssd,ssd_spread,discard=async,space_cache=v2,subvol=/@ dev/sda2 /mnt
mount -o rw,noatime,compress=zstd:3,ssd,ssd_spread,discard=async,space_cache=v2,subvol=/@home dev/sda2 /mnt/home
umount /mnt

echo 'Зеркала для загрузки.'
cat > /etc/pacman.d/mirrorlist <<EOF
##
## Arch Linux repository mirrorlist
## 
##

## Ukraine
Server = https://archlinux.astra.in.ua/\$repo/os/\$arch
Server = https://repo.endpoint.ml/archlinux/\$repo/os/\$arch
Server = https://fastmirror.pp.ua/archlinux/\$repo/os/\$arch
Server = https://archlinux.ip-connect.vn.ua/\$repo/os/\$arch
Server = https://mirror.mirohost.net/archlinux/\$repo/os/\$arch
Server = https://mirrors.nix.org.ua/linux/archlinux/\$repo/os/\$arch
EOF

echo 'Установка основных пакетов'
pacstrap /mnt base base-devel linux-zen linux-zen-headers linux-firmware nano dhcpcd netctl dbus

echo 'Настройка системы'
genfstab -pU /mnt >> /mnt/etc/fstab

arch-chroot /mnt sh -c "$(curl -fsSL git.io/JtvPw)"
