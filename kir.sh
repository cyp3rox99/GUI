#!/bin/bash

# إعداد أولي
echo "[*] Starting LVEUNIX full setup..."
sleep 1
export DEBIAN_FRONTEND=noninteractive

# اسم النظام
echo "lveunix" > /etc/hostname

# تثبيت الواجهة KDE
apt update && apt upgrade -y
apt install -y kde-plasma-desktop sddm kde-config-sddm

# ضبط SDDM
systemctl enable sddm

# إنشاء المستخدم
useradd -m -s /bin/bash 2zs
echo "2zs:2zs" | chpasswd
usermod -aG sudo 2zs

# تخصيص التيرمنال
echo 'echo -e "\n💀 Welcome to 2zs OS by 2z___s and lveuia 💀"' >> /home/2zs/.bashrc
echo 'PS1="2zs@lveuia💀:\w\$ "' >> /home/2zs/.bashrc
chown 2zs:2zs /home/2zs/.bashrc

# خلفيات هاكرية (مثال على صورة واحدة)
mkdir -p /usr/share/wallpapers/lveunix
wget -O /usr/share/wallpapers/lveunix/wallpaper1.jpg "https://i.ibb.co/ZKtQX1G/hacker-wallpaper.jpg"

# أدوات أساسية
apt install -y git curl wget gcc make python3 python3-pip net-tools build-essential

# أدوات GUI إضافية
apt install -y python3-tk qtbase5-dev

# مجلد أدوات النظام
mkdir -p /opt/lveunix-tools
echo "# هذا مجلد أدوات lveunix الرسمية" > /opt/lveunix-tools/README.md

# اختصار سطح المكتب
mkdir -p /home/2zs/Desktop
cat <<EOF > /home/2zs/Desktop/About-lveunix.desktop
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
chmod +x /home/2zs/Desktop/About-lveunix.desktop
chown 2zs:2zs /home/2zs/Desktop/About-lveunix.desktop

# تم
echo "[✔] LVEUNIX has been installed and customized."
echo "[!] Restart the system to enter your KDE environment as user 2zs."