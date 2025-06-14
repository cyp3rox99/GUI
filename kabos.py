#!/usr/bin/env python3
import os
import sys
import subprocess
import threading
import queue
import socket
import time

# تثبيت تلقائي للمكتبات المطلوبة
def install_package(pkg):
    try:
        __import__(pkg)
    except ImportError:
        print(f"[+] Installing missing package: {pkg}")
        subprocess.check_call([sys.executable, "-m", "pip", "install", pkg])

for pkg in ["paramiko", "python-nmap", "requests", "rich"]:
    install_package(pkg)

import paramiko
import nmap
import requests
from rich.console import Console
from rich.table import Table
from rich.live import Live
from rich.panel import Panel

console = Console()
THREADS = 30
DEFAULT_USERNAMES = ["root", "admin", "user", "test"]
DEFAULT_PASSWORDS = ["root", "admin", "123456", "password", "toor", "1234", "12345"]
PORTS_TO_CHECK = [
    21,    # FTP
    22,    # SSH
    23,    # Telnet
    25,    # SMTP
    53,    # DNS
    80,    # HTTP
    110,   # POP3
    139,   # SMB
    143,   # IMAP
    443,   # HTTPS
    445,   # SMB
    3306,  # MySQL
    3389,  # RDP
    5432,  # PostgreSQL
    5900,  # VNC
]

q_targets = queue.Queue()
lock = threading.Lock()
results = {}

# --- دوال مساعدة ---
def discover_hosts(network_cidr):
    console.print(f"[bold green]Scanning network:[/] {network_cidr} for live hosts ...")
    nm = nmap.PortScanner()
    nm.scan(hosts=network_cidr, arguments='-sn')
    hosts_list = nm.all_hosts()
    console.print(f"[bold cyan]Found[/] {len(hosts_list)} hosts")
    return hosts_list

def scan_ports(host):
    nm = nmap.PortScanner()
    try:
        ports_str = ",".join(str(p) for p in PORTS_TO_CHECK)
        nm.scan(host, arguments=f'-Pn -p {ports_str} --open')
        open_ports = []
        banners = {}
        for proto in nm[host].all_protocols():
            for port in nm[host][proto].keys():
                if nm[host][proto][port]['state'] == 'open':
                    open_ports.append(port)
                    # Banner grabbing بسيط
                    banner = grab_banner(host, port)
                    banners[port] = banner
        return open_ports, banners
    except Exception as e:
        return [], {}

def grab_banner(ip, port):
    try:
        sock = socket.socket()
        sock.settimeout(2)
        sock.connect((ip, port))
        sock.sendall(b"\r\n")
        banner = sock.recv(1024).decode(errors='ignore').strip()
        sock.close()
        return banner if banner else "N/A"
    except:
        return "N/A"

def try_ssh(host):
    for user in DEFAULT_USERNAMES:
        for pwd in DEFAULT_PASSWORDS:
            try:
                ssh = paramiko.SSHClient()
                ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
                ssh.connect(host, port=22, username=user, password=pwd, timeout=5)
                ssh.close()
                return (True, user, pwd)
            except Exception:
                pass
    return (False, None, None)

def try_ftp_anonymous(host):
    import ftplib
    try:
        ftp = ftplib.FTP(host, timeout=5)
        ftp.login()  # anonymous login
        ftp.quit()
        return True
    except Exception:
        return False

def check_http_default_page(host):
    try:
        url = f"http://{host}"
        resp = requests.get(url, timeout=5)
        if resp.status_code == 200 and len(resp.text) > 0:
            return True
        return False
    except:
        return False

def worker():
    while True:
        host = q_targets.get()
        if host is None:
            break
        status = {"open_ports": [], "banners": {}, "ssh": None, "ftp": None, "http": None}

        open_ports, banners = scan_ports(host)
        status["open_ports"] = open_ports
        status["banners"] = banners

        if 22 in open_ports:
            success, user, pwd = try_ssh(host)
            if success:
                status["ssh"] = f"[green]Success[/green] (User: {user} / Pass: {pwd})"
            else:
                status["ssh"] = "[red]Failed[/red]"
        else:
            status["ssh"] = "[yellow]SSH Port Closed[/yellow]"

        if 21 in open_ports:
            if try_ftp_anonymous(host):
                status["ftp"] = "[green]Anonymous FTP allowed[/green]"
            else:
                status["ftp"] = "[red]No anonymous FTP[/red]"
        else:
            status["ftp"] = "[yellow]FTP Port Closed[/yellow]"

        if 80 in open_ports or 443 in open_ports:
            if check_http_default_page(host):
                status["http"] = "[green]HTTP server active[/green]"
            else:
                status["http"] = "[red]No HTTP response[/red]"
        else:
            status["http"] = "[yellow]HTTP(S) Port Closed[/yellow]"

        with lock:
            results[host] = status

        q_targets.task_done()

def render_table():
    table = Table(title="SAW - Network Exploit Unit by majed")
    table.add_column("Target", style="cyan", no_wrap=True)
    table.add_column("Open Ports", style="magenta")
    table.add_column("SSH Access", style="green")
    table.add_column("FTP Access", style="blue")
    table.add_column("HTTP Status", style="yellow")
    table.add_column("Banners", style="white")

    for host, data in results.items():
        ports_str = ", ".join(str(p) for p in data["open_ports"]) if data["open_ports"] else "None"
        banners_str = "\n".join(f"{p}: {b}" for p,b in data["banners"].items())
        table.add_row(host, ports_str, data["ssh"], data["ftp"], data["http"], banners_str)
    return table

def main():
    if os.geteuid() != 0:
        console.print("[red]Please run this script as root (sudo).[/red]")
        sys.exit(1)

    if len(sys.argv) != 2:
        console.print(f"[yellow]Usage:[/] {sys.argv[0]} <network_cidr>")
        console.print(f"[yellow]Example:[/] {sys.argv[0]} 192.168.1.0/24")
        sys.exit(1)

    network_cidr = sys.argv[1]

    hosts = discover_hosts(network_cidr)
    if not hosts:
        console.print("[red]No hosts found. Exiting.[/red]")
        sys.exit(1)

    for host in hosts:
        q_targets.put(host)

    threads = []
    for _ in range(min(THREADS, len(hosts))):
        t = threading.Thread(target=worker, daemon=True)
        t.start()
        threads.append(t)

    with Live(render_table(), refresh_per_second=1, screen=True) as live:
        while any(t.is_alive() for t in threads) or not q_targets.empty():
            live.update(render_table())
            time.sleep(0.5)

    for _ in threads:
        q_targets.put(None)
    for t in threads:
        t.join()

    console.print("\n[bold green]Scan complete.[/bold green]")

if __name__ == "__main__":
    main()