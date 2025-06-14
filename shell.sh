#!/bin/bash

set -e
echo "[*] بدء إنشاء نسخة احتياطية من النظام الحالي إلى ملف ISO..."

# تحديث النظام
sudo apt update && sudo apt install -y curl git wget

# تثبيت الأدوات اللازمة
sudo apt install -y squashfs-tools xorriso grub-pc-bin grub-efi-bin mtools

# إنشاء مجلدات العمل
WORKDIR=~/myos-build
mkdir -p "$WORKDIR"/{chroot,iso}

echo "[*] نسخ النظام الحالي بالكامل..."
sudo rsync -aAXv /* "$WORKDIR/chroot" --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found","$WORKDIR"}

echo "[*] إعداد الإقلاع..."
sudo mkdir -p "$WORKDIR/iso/boot/grub"
echo 'set default=0
set timeout=5
menuentry "Boot My Custom OS" {
    linux /boot/vmlinuz root=/dev/sr0 quiet
    initrd /boot/initrd.img
}' | sudo tee "$WORKDIR/iso/boot/grub/grub.cfg"

echo "[*] نسخ الكيرنل والـ initrd..."
sudo cp /boot/vmlinuz-* "$WORKDIR/iso/boot/vmlinuz"
sudo cp /boot/initrd.img-* "$WORKDIR/iso/boot/initrd.img"

echo "[*] ضغط النظام إلى squashfs..."
sudo mksquashfs "$WORKDIR/chroot" "$WORKDIR/iso/filesystem.squashfs" -e boot

echo "[*] إنشاء ملف ISO..."
cd "$WORKDIR/iso"
sudo xorriso -as mkisofs \
  -iso-level 3 \
  -o ~/BlackNova-Cloned.iso \
  -full-iso9660-filenames \
  -volid "BLACKNOVA" \
  -eltorito-boot boot/grub/i386-pc/eltorito.img \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -eltorito-catalog boot/grub/boot.cat \
  -output ~/BlackNova-Cloned.iso \
  -graft-points . \
  -boot-load-size 4 -boot-info-table

echo "[✓] تم إنشاء النظام: ~/BlackNova-Cloned.iso"