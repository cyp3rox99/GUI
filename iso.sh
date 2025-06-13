#!/bin/bash

echo "🚀 بدء تجهيز مشروع BlackNova ISO..."

# تحديث النظام وتثبيت الأدوات المطلوبة
apt update && apt install -y live-build wget sudo curl

# إنشاء مجلد المشروع
mkdir -p ~/blacknova-iso/config/package-lists
cd ~/blacknova-iso

# تهيئة إعدادات live-build
lb config \
  --distribution bookworm \
  --architecture amd64 \
  --debian-installer live \
  --binary-images iso-hybrid \
  --bootappend-live "boot=live components username=kira hostname=BlackNova"

# حزمة البرامج المطلوبة
cat <<EOF > config/package-lists/blacknova.list.chroot
xfce4
xfce4-goodies
lightdm
lightdm-gtk-greeter
wget
sudo
curl
EOF

# إنشاء مجلدات التخصيص
mkdir -p config/includes.chroot/etc
mkdir -p config/includes.chroot/etc/lightdm
mkdir -p config/includes.chroot/home/kira/Pictures/Wallpapers

# إزالة هوية Debian
cat <<EOF > config/includes.chroot/etc/os-release
PRETTY_NAME="BlackNova OS by lveuia & 2zs"
NAME="BlackNova"
ID=blacknova
EOF

# تخصيص شاشة الدخول
cat <<EOF > config/includes.chroot/etc/lightdm/lightdm-gtk-greeter.conf
[greeter]
background=/usr/share/pixmaps/login_bg.jpg
EOF

# MOTD
echo "💀 Welcome to BlackNova Terminal — lveuia & 2zs" > config/includes.chroot/etc/motd

# تخصيص bash
mkdir -p config/includes.chroot/home/kira
cat << 'EOF' >> config/includes.chroot/home/kira/.bashrc
echo -e "\e[1;35m💀 Welcome to BlackNova — Powered by lveuia x 2zs\e[0m"
PS1='\e[1;32mkira@2zs:\e[1;36m\w\e[0m\$ '
EOF

# إنشاء مستخدم kira وكلمة السر
mkdir -p config/includes.chroot/usr/lib/live/config
cat << 'EOF' > config/includes.chroot/usr/lib/live/config/999-custom
#!/bin/sh

# إعداد المستخدم
useradd -m -s /bin/bash kira
echo "kira:kira" | chpasswd
usermod -aG sudo kira
EOF
chmod +x config/includes.chroot/usr/lib/live/config/999-custom

# تحميل الخلفيات الهكرية
wget -O config/includes.chroot/home/kira/Pictures/Wallpapers/hack1.jpg "https://i.imgur.com/nX5K9fT.jpg"
wget -O config/includes.chroot/home/kira/Pictures/Wallpapers/hack2.jpg "https://i.imgur.com/1OHz3bG.jpeg"
cp config/includes.chroot/home/kira/Pictures/Wallpapers/hack1.jpg config/includes.chroot/usr/share/pixmaps/login_bg.jpg

# إعطاء الصلاحيات
chown -R kira:kira config/includes.chroot/home/kira

# البدء ببناء ISO
echo "⚙️ جاري بناء ISO... استعد"
lb build

# نقل الناتج
mkdir -p ~/blacknova-output
mv *.iso ~/blacknova-output/

echo "✅ تم إنشاء BlackNova ISO في: ~/blacknova-output/"