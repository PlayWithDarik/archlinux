#!/bin/bash
read -p "Введите имя компьютера: " hostname
read -p "Введите имя пользователя: " username

echo 'Прописываем имя компьютера'
echo $hostname > /etc/hostname
ln -svf /usr/share/zoneinfo/Europe/Kiev /etc/localtime

echo '3.4 Добавляем русскую локаль системы'
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen 

echo 'Обновим текущую локаль системы'
locale-gen

echo 'Указываем язык системы'
echo 'LANG="ru_RU.UTF-8"' > /etc/locale.conf

echo 'Вписываем KEYMAP=ru FONT=cyr-sun16'
echo 'KEYMAP=ru' >> /etc/vconsole.conf
echo 'FONT=cyr-sun16' >> /etc/vconsole.conf

echo 'Создадим загрузочный RAM диск'
mkinitcpio -p linux

echo '3.5 Устанавливаем загрузчик'
pacman -Syy
pacman -S grub --noconfirm 
grub-install /dev/sda

echo 'Обновляем grub.cfg'
grub-mkconfig -o /boot/grub/grub.cfg

echo 'Ставим программу для Wi-fi'
read -p "1 - Да, 0 - Нет: " wifi_setting
if   [[ $wifi_setting == 0 ]]; then
  echo 'Пропущенно'
elif [[ $wifi_setting == 1 ]]; then
  pacman -S dialog wpa_supplicant --noconfirm
fi

echo 'Добавляем пользователя'
useradd -m -g users -G wheel -s /bin/bash $username

echo 'Создаем root пароль'
passwd

echo 'Устанавливаем пароль пользователя'
passwd $username

echo 'Устанавливаем SUDO'
echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers

echo 'Раскомментируем репозиторий multilib Для работы 32-битных приложений в 64-битной системе.'
echo '[multilib]' >> /etc/pacman.conf
echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
pacman -Syy

echo "Куда устанавливем Arch Linux на виртуальную машину?"
read -p "1 - Да, 0 - Нет: " vm_setting
if [[ $vm_setting == 0 ]]; then
  gui_install="xorg-server xorg-drivers xorg-xinit"
elif [[ $vm_setting == 1 ]]; then
  gui_install="xorg-server xorg-drivers xorg-xinit virtualbox-guest-utils"
fi

echo 'Ставим иксы и драйвера'
pacman -S $gui_install

echo "Выбираем DE"
read -p "1 - XFCE, 2 - MATE, 3 - GNOME, 4 - KDE:" de_setting
if   [[ $de_setting == 1 ]]; then
  pacman -S xfce4 xfce4-goodies --noconfirm
elif [[ $de_setting == 2 ]]; then
  pacman -S mate mate-extra --noconfirm
elif [[ $de_setting == 3 ]]; then
  pacman -S gnome gnome-extra --noconfirm
elif [[ $de_setting == 4 ]]; then
  pacman -S plasma plasma-desktop konsole --noconfirm
fi

echo 'Выбираем DM'
read -p "0 - Пропустить, 1 - LIGHTDM, 2 - SDDM, 3 - GDM:" dm_setting
if   [[ $dm_setting == 0 ]]; then
  echo 'Пропущенно'
elif [[ $dm_setting == 1 ]]; then
  pacman -S lightdm lightdm-gtk-greeter-settings lightdm-gtk-greeter --noconfirm
  systemctl enable lightdm.service -f
elif [[ $dm_setting == 2 ]]; then
  pacman -S sddm sddm-kcm --noconfirm
  systemctl enable sddm.service -f
elif [[ $dm_setting == 3 ]]; then
  pacman -S gdm --noconfirm
  systemctl enable gdm.service -f
fi

echo 'Ставим шрифты'
pacman -S ttf-liberation ttf-dejavu --noconfirm 

echo 'Ставим сеть'
pacman -S networkmanager network-manager-applet ppp --noconfirm

echo 'Подключаем автозагрузку менеджера входа и интернет'
systemctl enable NetworkManager

echo 'Установка завершена! Перезагрузите систему.'
exit
