#!/bin/bash

echo "🔥 Starting 2zs OS Setup..."

# تحديث النظام
apt update && apt upgrade -y

# تثبيت واجهة KDE ومكونات العرض
apt install -y kde-plasma-desktop sddm xorg dbus policykit-1 network-manager wget curl sudo fonts-powerline

# تعيين SDDM كمدير جلسة
echo "/usr/bin/sddm" > /etc/X11/default-display-manager

# تفعيل Network Manager
systemctl enable NetworkManager
systemctl start NetworkManager

# إنشاء مستخدم 2zs
useradd -m -s /bin/bash 2zs
echo "2zs:2zs" | chpasswd
usermod -aG sudo 2zs

# إعداد التيرمنال بـ bashrc
echo '
echo "💀 Welcome to 2zs OS by 2z___s"
PS1="\e[1;31m2zs@2zs:\w\\$ \e[0m"
' >> /home/2zs/.bashrc

# تحميل خلفية هاكرية
mkdir -p /home/2zs/Pictures
wget -O /home/2zs/Pictures/2zs-wallpaper.jpg https://i.imgur.com/0n6VJQz.jpeg

# إعداد شاشة الدخول بخلفية مخصصة
mkdir -p /usr/share/sddm/themes/2zs
cp /home/2zs/Pictures/2zs-wallpaper.jpg /usr/share/sddm/themes/2zs/background.jpg
echo "[Theme]
Current=2zs" >> /etc/sddm.conf

# تخصيص هوية النظام
sed -i 's/Debian/2zs OS by 2z___s/g' /etc/os-release
hostnamectl set-hostname 2zs-os

# تعيين ملكية الملفات
chown -R 2zs:2zs /home/2zs

echo "✅ 2zs OS GUI setup complete. Reboot now and log in as 2zs / 2zs"