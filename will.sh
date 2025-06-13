#!/bin/bash

echo "🚀 بدء تثبيت الواجهة الرسومية Phantom OS ..."

# تحديث النظام (بدون ترقية كاملة لتسريع التثبيت)
apt update

# تثبيت XFCE و LightDM بدون الحزم الزائدة (تخفيف)
apt install -y xfce4 lightdm lightdm-gtk-greeter wget sudo

# حذف المستخدم القديم إذا موجود
id -u lveuia &>/dev/null && userdel -r lveuia

# إنشاء المستخدم الجديد بكلمة مرور 2zs
useradd -m -s /bin/bash lveuia
echo "lveuia:2zs" | chpasswd
usermod -aG sudo lveuia

# تغيير اسم النظام (hostname) إلى phantom-os
hostnamectl set-hostname phantom-os

# إزالة خلفية ديبيان القديمة لو موجودة
rm -f /usr/share/pixmaps/login_bg.jpg

# تحميل خلفية هكرية جديدة (مظلمة وعصرية)
mkdir -p /home/lveuia/Pictures/Wallpapers
wget -O /home/lveuia/Pictures/Wallpapers/hacker_bg.jpg https://images.alphacoders.com/109/1097684.jpg
cp /home/lveuia/Pictures/Wallpapers/hacker_bg.jpg /usr/share/pixmaps/login_bg.jpg

# إعداد شاشة الدخول بخلفية جديدة
echo "[greeter]
background=/usr/share/pixmaps/login_bg.jpg" > /etc/lightdm/lightdm-gtk-greeter.conf

# تخصيص bash للمستخدم: بروبت بسيط وأنيق مع ألوان أخضر وآثار هكرية
cat << 'EOF' >> /home/lveuia/.bashrc

# رسالة ترحيب
echo -e "\e[1;32m💀 Welcome to Phantom OS - lveuia @ 2zs 💻\e[0m"

# إعداد PS1 بسيط، أخضر، ومميز
PS1="\e[1;32m\u@2zs:\w\$ \e[0m"
EOF

# إعطاء ملكية الملفات للمستخدم
chown -R lveuia:lveuia /home/lveuia

echo "✅ تم تثبيت الواجهة بنجاح. أعد التشغيل وسجّل دخولك بـ lveuia / 2zs"