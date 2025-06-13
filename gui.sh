#!/bin/bash

echo "🚀 بدء تثبيت الواجهة الرسومية Phantom OS ..."

# تحديث النظام
apt update && apt upgrade -y

# تثبيت XFCE و LightDM
apt install -y xfce4 xfce4-goodies lightdm lightdm-gtk-greeter wget sudo

# إنشاء المستخدم
useradd -m -s /bin/bash lveuia
echo "lveuia:1234" | chpasswd
usermod -aG sudo lveuia

# تغيير اسم النظام
sed -i 's/Debian/2z___s x lveuia/g' /etc/os-release
hostnamectl set-hostname phantom-os

# تحميل الخلفية
mkdir -p /home/lveuia/Pictures/Wallpapers
wget -O /home/lveuia/Pictures/Wallpapers/phantom.jpg https://images2.alphacoders.com/132/1320723.jpeg

# تعيين الخلفية بعد تسجيل الدخول (ستحتاج تنفيذ يدوي من داخل الجلسة لاحقًا)
cp /home/lveuia/Pictures/Wallpapers/phantom.jpg /usr/share/pixmaps/login_bg.jpg

# إعداد شاشة الدخول
echo "[greeter]
background=/usr/share/pixmaps/login_bg.jpg" > /etc/lightdm/lightdm-gtk-greeter.conf

# تخصيص bash للمستخدم
echo 'echo "💀 Welcome to Phantom OS - 2z___s x lveuia 💻"' >> /home/lveuia/.bashrc
echo 'PS1="\e[1;32m\u@2z___s-x-lveuia:\w\\$ \e[0m"' >> /home/lveuia/.bashrc

# إعطاء ملكية الملفات للمستخدم
chown -R lveuia:lveuia /home/lveuia

echo "✅ تم تثبيت الواجهة بنجاح. أعد التشغيل وسجّل دخولك بـ lveuia / 1234"