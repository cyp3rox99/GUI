#!/bin/bash

echo "💀 بدء إعداد نظام LVEUNIX ..."

# إعداد أولي
export DEBIAN_FRONTEND=noninteractive

# تغيير اسم النظام
echo "lveunix" | sudo tee /etc/hostname
sudo hostnamectl set-hostname lveunix

# تحديث النظام وتثبيت KDE + SDDM
sudo apt update && sudo apt upgrade -y
sudo apt install -y kde-plasma-desktop sddm kde-config-sddm

# تفعيل SDDM
echo "/usr/bin/sddm" | sudo tee /etc/X11/default-display-manager
sudo systemctl enable sddm

# إنشاء مستخدم جديد: 2zs
sudo useradd -m -s /bin/bash 2zs
echo "2zs:2zs" | sudo chpasswd
sudo usermod -aG sudo 2zs

# تخصيص التيرمنال
echo 'echo -e "\n💀 Welcome to 2zs OS by 2z___s and lveuia 💀"' | sudo tee -a /home/2zs/.bashrc
echo 'PS1="2zs@lveuia💀:\w\$ "' | sudo tee -a /home/2zs/.bashrc
sudo chown 2zs:2zs /home/2zs/.bashrc

# تحميل خلفية هاكرية
sudo mkdir -p /usr/share/wallpapers/lveunix
sudo wget -O /usr/share/wallpapers/lveunix/wallpaper1.jpg "https://i.ibb.co/ZKtQX1G/hacker-wallpaper.jpg"

# تثبيت أدوات أساسية للمطورين
sudo apt install -y git curl wget gcc make python3 python3-pip net-tools build-essential

# أدوات رسومية إضافية
sudo apt install -y python3-tk qtbase5-dev

# إنشاء مجلد أدوات النظام
sudo mkdir -p /opt/lveunix-tools
echo "# أدوات نظام lveunix الرسمية" | sudo tee /opt/lveunix-tools/README.md

# إنشاء اختصار سطح المكتب
sudo mkdir -p /home/2zs/Desktop
cat <<EOF | sudo tee /home/2zs/Desktop/About-lveunix.desktop
[Desktop Entry]
Version=1.0
Name=About lveunix
Comment=Custom OS by 2zs and lveuia
Exec=xdg-open /opt/lveunix-tools/README.md
Icon=utilities-terminal
Terminal=false
Type=Application
Categories=Utility;
EOF

sudo chmod +x /home/2zs/Desktop/About-lveunix.desktop
sudo chown 2zs:2zs /home/2zs/Desktop/About-lveunix.desktop

echo "✅ تم بناء نظام LVEUNIX بنجاح!"
echo "🔁 أعد التشغيل وسجّل دخولك كمستخدم: 2zs / 2zs"