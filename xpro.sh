#!/bin/bash

echo "[*] بدء تخصيص نظام lveunix..."

# تغيير اسم النظام
echo "lveunix" | sudo tee /etc/hostname
sudo hostnamectl set-hostname lveunix

# تثبيت الواجهة KDE و SDDM
sudo apt update && sudo apt install -y kde-plasma-desktop sddm

# تفعيل SDDM كمدير جلسة
echo "/usr/bin/sddm" | sudo tee /etc/X11/default-display-manager
sudo systemctl enable sddm

# تخصيص التيرمنال
echo 'echo -e "\n💀 تم الصنع من قبل 2zs و lveuia 💀"' >> ~/.bashrc
echo 'PS1="lveuia@2zs💀:\w\\$ "' >> ~/.bashrc

# تحميل خلفية هاكرية وتعيينها
sudo mkdir -p /usr/share/wallpapers/lveunix
sudo wget -O /usr/share/wallpapers/lveunix/hacker.jpg https://i.ibb.co/ZKtQX1G/hacker-wallpaper.jpg

# تثبيت الأدوات الأساسية
sudo apt install -y git curl wget gcc make python3 python3-pip net-tools build-essential python3-tk qtbase5-dev

# مجلد أدوات النظام
sudo mkdir -p /opt/lveunix-tools
echo "# أدوات نظام lveunix الرسمية" | sudo tee /opt/lveunix-tools/README.md

echo "[✔] تم إعداد lveunix بنجاح! أعد التشغيل لاستخدام KDE."