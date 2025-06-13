#!/bin/bash

echo "🚀 بدء تخصيص وتغيير هوية Kali Linux إلى Phantom OS ..."

# اسم النظام الجديد
NEW_NAME="Phantom OS"
NEW_HOSTNAME="phantom-os"

# تغيير اسم الجهاز (hostname)
hostnamectl set-hostname "$NEW_HOSTNAME"

# تغيير اسم النظام في ملفات تعريف النظام
sed -i "s/^PRETTY_NAME=.*/PRETTY_NAME=\"$NEW_NAME\"/" /etc/os-release
sed -i "s/^NAME=.*/NAME=\"$NEW_NAME\"/" /etc/os-release
sed -i "s/^VERSION=.*/VERSION=\"by 2z___s x lveuia\"/" /etc/os-release

# تغيير ملف /etc/hostname
echo "$NEW_HOSTNAME" > /etc/hostname

# تغيير ملف /etc/hosts
sed -i "s/127.0.1.1.*/127.0.1.1\t$NEW_HOSTNAME/" /etc/hosts

# تخصيص موجه الأوامر (الترمينال) للمستخدم الحالي
cat << 'EOF' >> ~/.bashrc

# ترحيب
echo -e "\e[1;36m💀 Welcome to Phantom OS - 2z___s x lveuia 💻\e[0m"

# PS1 بسيط وأنيق
PS1="\e[1;35m\u@2zs:\w\$ \e[0m"
EOF

# تعيين خلفية هكرية (خلفية كالي الافتراضية غالبًا في /usr/share/images/desktop-base/)
HACKER_WALLPAPER_URL="https://images.alphacoders.com/109/1097684.jpg"
WALLPAPER_PATH="/usr/share/images/phantom_hacker.jpg"
wget -O "$WALLPAPER_PATH" "$HACKER_WALLPAPER_URL"

# تغيير الخلفية على بيئة XFCE (لو كانت موجودة)
if command -v xfconf-query &> /dev/null; then
    xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -s "$WALLPAPER_PATH"
    xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/backdrop-cycle-enable -s false
fi

echo "✅ تم تغيير هوية النظام إلى $NEW_NAME وتم تخصيص الترمنال والخلفية بنجاح."
echo "📌 أعد التشغيل لتطبيق التغييرات بالكامل: sudo reboot"