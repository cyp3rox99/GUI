#!/bin/bash

echo "🚀 بدء بناء نظام BlackNova ..."

# تحديث النظام
apt update && apt upgrade -y

# تثبيت الواجهة XFCE وخادم العرض + مدير تسجيل الدخول
apt install -y xfce4 xfce4-goodies lightdm lightdm-gtk-greeter wget sudo curl

# إنشاء المستخدم kira بكلمة السر kira
useradd -m -s /bin/bash kira
echo "kira:kira" | chpasswd
usermod -aG sudo kira

# تغيير اسم النظام إلى BlackNova
hostnamectl set-hostname BlackNova
sed -i 's/Debian/BlackNova/g' /etc/os-release
echo "PRETTY_NAME=\"BlackNova OS by lveuia & 2zs\"" > /etc/os-release

# تخصيص التيرمنال: ألوان وPS1
cat << 'EOF' >> /home/kira/.bashrc
echo -e "\e[1;35m💀 Welcome to BlackNova — Powered by lveuia x 2zs\e[0m"
PS1='\e[1;32mkira@2zs:\e[1;36m\w\e[0m\$ '
EOF

# تنزيل خلفيات تهكير حصرية
mkdir -p /home/kira/Pictures/Wallpapers
wget -O /home/kira/Pictures/Wallpapers/hack.jpg https://i.imgur.com/nX5K9fT.jpg
wget -O /home/kira/Pictures/Wallpapers/hack2.jpg https://i.imgur.com/1OHz3bG.jpeg

# خلفية شاشة تسجيل الدخول LightDM
mkdir -p /usr/share/pixmaps
cp /home/kira/Pictures/Wallpapers/hack.jpg /usr/share/pixmaps/login_bg.jpg
echo "[greeter]" > /etc/lightdm/lightdm-gtk-greeter.conf
echo "background=/usr/share/pixmaps/login_bg.jpg" >> /etc/lightdm/lightdm-gtk-greeter.conf

# إزالة الشعارات القديمة من grub
sed -i 's/Debian GNU\/Linux/BlackNova OS/g' /etc/default/grub
update-grub

# تغيير MOTD (رسالة تسجيل الدخول)
echo "💀 Welcome to BlackNova Terminal — Access by lveuia & 2zs" > /etc/motd

# ملكية الملفات للمستخدم
chown -R kira:kira /home/kira

# تنظيف النظام
apt purge -y nano games popularity-contest
apt autoremove -y && apt clean

echo "✅ تم تثبيت BlackNova OS بنجاح. أعد التشغيل الآن وسجّل الدخول بـ: kira / kira"