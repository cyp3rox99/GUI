# 2z___s - OSINT CLI Nightmare by 2z___s 💀
# Version 0.2 | Kali & BlackArch

import socket

try:
    import whois
except:
    print("[!] مكتبة whois غير مثبّتة. ثبّتها يدويًا بالأمر:")
    print("    pip install whois")
    exit()

def banner():
    print("""
███████╗███████╗    ███████╗███████╗
██╔════╝██╔════╝    ██╔════╝██╔════╝
█████╗  ███████╗    █████╗  ███████╗
██╔══╝  ╚════██║    ██╔══╝  ╚════██║
██║     ███████║    ███████╗███████║
╚═╝     ╚══════╝    ╚══════╝╚══════╝
        2z___s OSINT NIGHTMARE 💀
-----------------------------------------
أدخل أي شيء: دومين - رقم - اسم - موقع
    """)

def whois_lookup(target):
    print("\n[+] WHOIS:")
    try:
        info = whois.whois(target)
        print(info)
    except:
        print("[-] Whois غير متاح أو غير صالح.")

def ip_lookup(target):
    print("\n[+] IP Lookup:")
    try:
        ip = socket.gethostbyname(target)
        print(f"IP Address: {ip}")
    except:
        print("[-] تعذر استخراج IP.")

def phone_analysis(phone):
    print("\n[+] Phone Analysis:")
    if not phone.isdigit():
        print("[-] هذا ليس رقمًا.")
        return

    if phone.startswith("20"):
        print("▪ الدولة: مصر 🇪🇬")
    elif phone.startswith("966"):
        print("▪ الدولة: السعودية 🇸🇦")
    elif phone.startswith("212"):
        print("▪ الدولة: المغرب 🇲🇦")
    else:
        print("▪ الدولة: غير معروفة")
    print("📌 لتحليل أعمق، اربطه بواجهة API لاحقًا.")

def main():
    banner()
    target = input("👁️‍🗨️ الهدف: ").strip()

    if target.isdigit():
        phone_analysis(target)
    else:
        whois_lookup(target)
        ip_lookup(target)

    print("\n✅ التحليل انتهى — بواسطة 2z___s 💀")

if __name__ == "__main__":
    main()