#!/bin/bash

echo "🎨 بدء تخصيص Phantom OS باسم 2z___s x lveuia..."

# 1. تثبيت XFCE و LightDM
sudo apt update
sudo apt install -y xfce4 xfce4-goodies lightdm lightdm-gtk-greeter plymouth wget sudo

# 2. إضافة مستخدم lveuia
sudo useradd -m -s /bin/bash lveuia
echo "lveuia:1234" | sudo chpasswd
sudo usermod -aG sudo lveuia

# 3. إعداد LightDM بدون تسجيل دخول تلقائي
sudo bash -c 'echo "[Seat:*]
greeter-session=lightdm-gtk-greeter
" > /etc/lightdm/lightdm.conf'

# 4. تحميل خلفية احترافية (مستوحاة من كالي)
mkdir -p /home/lveuia/Pictures/Wallpapers
wget -O /home/lveuia/Pictures/Wallpapers/phantom-bg.jpg https://images2.alphacoders.com/132/1320723.jpeg

# 5. تخصيص شاشة الدخول
sudo cp /home/lveuia/Pictures/Wallpapers/phantom-bg.jpg /usr/share/pixmaps/login_bg.jpg
sudo bash -c 'echo "[greeter]
background=/usr/share/pixmaps/login_bg.jpg
theme-name=Adwaita
" > /etc/lightdm/lightdm-gtk-greeter.conf'

# 6. تغيير اسم النظام
sudo sed -i 's/Debian/2z___s x lveuia/g' /etc/os-release
sudo hostnamectl set-hostname phantom-os

# 7. تخصيص التيرمنال بترحيب كتابي واضح
echo '
echo "🔐 Welcome, lveuia | System: 2z___s x lveuia"
echo "📡 Phantom OS ready for recon, attack, or defense."
echo "💀 Be ethical. Be legendary."
' >> /home/lveuia/.bashrc

# 8. تحديث هوية Bash
echo 'PS1="\e[1;32m\u@2z___s-x-lveuia:\w\$ \e[0m"' >> /home/lveuia/.bashrc

# 9. ملكية الملفات
chown -R lveuia:lveuia /home/lveuia

echo "✅ تم إعداد Phantom OS بنجاح - واجهة مخصصة، ترحيب شخصي، وتوقيعك في كل زاوية"