#!/bin/bash

echo "[*] تحديث النظام وتثبيت المتطلبات..."

sudo apt update
sudo apt install -y python3 python3-pip nmap

echo "[*] تثبيت مكتبات بايثون المطلوبة..."
pip3 install --user pyqt5 paramiko python-nmap netifaces scapy

echo "[*] إنشاء مجلد الأداة في /opt/ssh_tool"
sudo mkdir -p /opt/ssh_tool
sudo chown $USER:$USER /opt/ssh_tool

echo "[*] إنشاء سكربت الأداة المتقدم..."

cat > /opt/ssh_tool/ssh_gui_tool.py << 'EOF'
import sys
import csv
import os
import subprocess
from PyQt5.QtWidgets import (
    QApplication, QWidget, QVBoxLayout, QPushButton, QListWidget,
    QLabel, QLineEdit, QFileDialog, QMessageBox, QHBoxLayout, QProgressBar
)
from PyQt5.QtGui import QColor, QPalette
import nmap
import paramiko
import netifaces
import threading
import time

class SSHGui(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("SSH Network Tool Advanced")
        self.resize(600, 500)

        self.layout = QVBoxLayout()

        self.subnet_layout = QHBoxLayout()
        self.subnet_label = QLabel("Subnet (مثال: 192.168.1.0/24):")
        self.subnet_input = QLineEdit("192.168.1.0/24")
        self.subnet_layout.addWidget(self.subnet_label)
        self.subnet_layout.addWidget(self.subnet_input)
        self.layout.addLayout(self.subnet_layout)

        self.status_label = QLabel("اضغط 'Scan Network' لمسح الأجهزة")
        self.layout.addWidget(self.status_label)

        self.progress_bar = QProgressBar()
        self.progress_bar.setVisible(False)
        self.layout.addWidget(self.progress_bar)

        self.scan_button = QPushButton("Scan Network")
        self.scan_button.clicked.connect(self.scan_network_thread)
        self.layout.addWidget(self.scan_button)

        self.devices_list = QListWidget()
        self.layout.addWidget(self.devices_list)

        btn_layout = QHBoxLayout()
        self.connect_button = QPushButton("Connect via SSH")
        self.connect_button.clicked.connect(self.try_ssh_connect_thread)
        btn_layout.addWidget(self.connect_button)

        self.load_button = QPushButton("Load Devices CSV")
        self.load_button.clicked.connect(self.load_csv)
        btn_layout.addWidget(self.load_button)

        self.save_button = QPushButton("Save Devices CSV")
        self.save_button.clicked.connect(self.save_csv)
        btn_layout.addWidget(self.save_button)

        self.layout.addLayout(btn_layout)

        key_layout = QHBoxLayout()
        self.key_label = QLabel("SSH Private Key (اختياري):")
        self.key_path = QLineEdit()
        self.key_browse = QPushButton("Browse")
        self.key_browse.clicked.connect(self.browse_key)
        key_layout.addWidget(self.key_label)
        key_layout.addWidget(self.key_path)
        key_layout.addWidget(self.key_browse)
        self.layout.addLayout(key_layout)

        self.setLayout(self.layout)

        self.devices = []
        self.accounts = [("root","1234"), ("admin","password"), ("user","admin"), ("root","toor")]
        self.stop_scan_flag = False

    def scan_network_thread(self):
        thread = threading.Thread(target=self.scan_network)
        thread.start()

    def scan_network(self):
        self.stop_scan_flag = False
        subnet = self.subnet_input.text().strip()
        if not subnet:
            self.status_label.setText("يرجى إدخال نطاق الشبكة")
            return
        self.status_label.setText("جار المسح ... يرجى الانتظار")
        self.progress_bar.setVisible(True)
        self.progress_bar.setValue(0)
        self.devices_list.clear()
        self.devices = []

        nm = nmap.PortScanner()
        try:
            nm.scan(hosts=subnet, arguments='-sn')
            hosts = nm.all_hosts()
            total_hosts = len(hosts)
            count = 0
            for host in hosts:
                if self.stop_scan_flag:
                    break
                count +=1
                self.progress_bar.setValue(int((count/total_hosts)*100))
                if nm[host].state() == 'up':
                    mac = nm[host]['addresses'].get('mac', 'غير معروف')
                    try:
                        hostname = nm[host].hostname() or "غير معروف"
                    except:
                        hostname = "غير معروف"
                    item_text = f"{host} | MAC: {mac} | Hostname: {hostname}"
                    self.devices.append({'ip': host, 'mac': mac, 'hostname': hostname})
                    self.devices_list.addItem(item_text)
                QApplication.processEvents()
            self.status_label.setText(f"تم العثور على {len(self.devices)} جهازًا")
        except Exception as e:
            self.status_label.setText(f"خطأ أثناء المسح: {e}")
        self.progress_bar.setVisible(False)

    def try_ssh_connect_thread(self):
        thread = threading.Thread(target=self.try_ssh_connect)
        thread.start()

    def try_ssh_connect(self):
        selected = self.devices_list.currentItem()
        if not selected:
            self.status_label.setText("اختر جهازاً من القائمة أولاً")
            return
        ip = selected.text().split()[0]
        self.status_label.setText(f"محاولة الاتصال بـ {ip} ...")

        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

        keyfile = self.key_path.text().strip()
        use_key = False
        if keyfile and os.path.isfile(keyfile):
            use_key = True

        connected = False
        for user, pwd in self.accounts:
            try:
                if use_key:
                    key = paramiko.RSAKey.from_private_key_file(keyfile)
                    client.connect(ip, username=user, pkey=key, timeout=5)
                else:
                    client.connect(ip, username=user, password=pwd, timeout=5)
                self.status_label.setText(f"نجح الاتصال بـ {ip} باسم {user}")
                # تنفيذ أمر بعد الاتصال
                stdin, stdout, stderr = client.exec_command('uname -a')
                output = stdout.read().decode()
                QMessageBox.information(self, "معلومات النظام", output)
                client.close()
                connected = True
                break
            except Exception as e:
                # تجاهل الأخطاء ومحاولة الحساب التالي
                pass

        if not connected:
            self.status_label.setText(f"فشل الاتصال بـ {ip} بكل المحاولات")

    def browse_key(self):
        filename, _ = QFileDialog.getOpenFileName(self, "اختر ملف مفتاح SSH الخاص", "", "Key Files (*)")
        if filename:
            self.key_path.setText(filename)

    def save_csv(self):
        if not self.devices:
            self.status_label.setText("لا توجد أجهزة للحفظ")
            return
        filename, _ = QFileDialog.getSaveFileName(self, "حفظ الأجهزة كـ CSV", "", "CSV Files (*.csv)")
        if filename:
            try:
                with open(filename, 'w', newline='', encoding='utf-8') as csvfile:
                    fieldnames = ['ip', 'mac', 'hostname']
                    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
                    writer.writeheader()
                    for d in self.devices:
                        writer.writerow(d)
                self.status_label.setText(f"تم حفظ الأجهزة في {filename}")
            except Exception as e:
                self.status_label.setText(f"خطأ في الحفظ: {e}")

    def load_csv(self):
        filename, _ = QFileDialog.getOpenFileName(self, "تحميل الأجهزة من CSV", "", "CSV Files (*.csv)")
        if filename:
            try:
                with open(filename, newline='', encoding='utf-8') as csvfile:
                    reader = csv.DictReader(csvfile)
                    self.devices = []
                    self.devices_list.clear()
                    for row in reader:
                        self.devices.append(row)
                        item_text = f"{row['ip']} | MAC: {row.get('mac','غير معروف')} | Hostname: {row.get('hostname','غير معروف')}"
                        self.devices_list.addItem(item_text)
                self.status_label.setText(f"تم تحميل الأجهزة من {filename}")
            except Exception as e:
                self.status_label.setText(f"خطأ في التحميل: {e}")

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = SSHGui()
    window.show()
    sys.exit(app.exec_())
EOF

echo "[*] إنشاء سكربت تشغيل الاختصار /usr/local/bin/ssh"

cat > /tmp/ssh_launcher.sh << 'EOF'
#!/bin/bash
python3 /opt/ssh_tool/ssh_gui_tool.py
EOF

sudo mv /tmp/ssh_launcher.sh /usr/local/bin/ssh
sudo chmod +x /usr/local/bin/ssh

echo "[*] تم الانتهاء! يمكنك الآن تشغيل الأداة بكتابة الأمر: ssh"