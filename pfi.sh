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
mount /dev/sda2 /mnt
btrfs su cr /mnt/@
btrfs su cr /mnt/@home
btrfs su cr /mnt/@root
btrfs su cr /mnt/@srv
btrfs su cr /mnt/@log
btrfs su cr /mnt/@cache
btrfs su cr /mnt/@tmp
btrfs su li /mnt
cd /
umount /mnt
mount -o defaults,noatime,compress=zstd,commit=120,subvol=@ /dev/sda2 /mnt
mkdir -p /mnt/{home,root,srv,var/log,var/cache,tmp}
lsblk
mount -o defaults,noatime,compress=zstd,commit=120,subvol=@home /dev/sda3 /mnt/home
mount -o defaults,noatime,compress=zstd,commit=120,subvol=@root /dev/sda3 /mnt/root
mount -o defaults,noatime,compress=zstd,commit=120,subvol=@srv /dev/sda3 /mnt/srv
mount -o defaults,noatime,compress=zstd,commit=120,subvol=@log /dev/sda3 /mnt/var/log
mount -o defaults,noatime,compress=zstd,commit=120,subvol=@cache /dev/sda3 /mnt/var/cache
mount -o defaults,noatime,compress=zstd,commit=120,subvol=@tmp /dev/sda3 /mnt/tmp

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
