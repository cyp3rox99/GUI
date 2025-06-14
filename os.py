#!/usr/bin/env python3
"""
Ultimate OSINT Tool - Comprehensive Open-Source Intelligence Gathering
Single-file implementation with all major OSINT capabilities
"""

import argparse
import json
import dns.resolver
import whois
import socket
import requests
from ipwhois import IPWhois
import shodan
import re
from datetime import datetime
from urllib.parse import urlparse
import os
import sys
from concurrent.futures import ThreadPoolExecutor

class OSINTTool:
    def __init__(self):
        self.banner = r"""
         ___  ____ ____ ___ _____ _____
        / _ \/ ___/ ___|_ _|_   _| ____|
       | | | \___ \___ \| |  | | |  _|
       | |_| |___) |__) | |  | | | |___
        \___/|____/____/___| |_| |_____|
           The Ultimate OSINT Tool v2.0
        """
        self.version = "2.0"
        self.author = "by majed (ethical use only)"
        self.api_keys = {}
        self.load_config()
        
    def load_config(self):
        """Load API keys from environment variables"""
        self.api_keys['shodan'] = os.getenv('SHODAN_API_KEY', '')
        self.api_keys['virustotal'] = os.getenv('VIRUSTOTAL_API_KEY', '')

    # Domain Intelligence Module
    def domain_intel(self, domain):
        """Comprehensive domain investigation"""
        results = {
            'domain': domain,
            'timestamp': str(datetime.now()),
            'whois': self.get_whois(domain),
            'dns': self.get_dns_records(domain),
            'subdomains': self.find_subdomains(domain),
            'geoip': self.get_domain_geoip(domain),
            'http_headers': self.get_http_headers(domain),
            'technologies': self.detect_technologies(domain),
            'security': self.check_security_headers(domain)
        }
        
        if self.api_keys['virustotal']:
            results['virustotal'] = self.virustotal_scan(domain)
            
        return results

    def get_whois(self, domain):
        """Retrieve WHOIS information"""
        try:
            return whois.whois(domain)
        except Exception as e:
            return f"WHOIS lookup failed: {str(e)}"

    def get_dns_records(self, domain):
        """Retrieve comprehensive DNS records"""
        record_types = ['A', 'AAAA', 'MX', 'NS', 'SOA', 'TXT', 'CNAME']
        results = {}
        
        for record in record_types:
            try:
                answers = dns.resolver.resolve(domain, record)
                results[record] = [str(r) for r in answers]
            except:
                continue
                
        return results

    def find_subdomains(self, domain):
        """Discover subdomains using common techniques"""
        subdomains = set()
        wordlist = ['www', 'mail', 'ftp', 'admin', 'api', 'test', 'dev', 'staging']
        
        def check_subdomain(sub):
            try:
                dns.resolver.resolve(f"{sub}.{domain}", 'A')
                subdomains.add(f"{sub}.{domain}")
            except:
                pass
                
        with ThreadPoolExecutor(max_workers=10) as executor:
            executor.map(check_subdomain, wordlist)
            
        return list(subdomains)

    def get_domain_geoip(self, domain):
        """Get geolocation data for domain IP"""
        try:
            a_record = dns.resolver.resolve(domain, 'A')[0]
            ip = str(a_record)
            return self.ip_intel(ip)
        except Exception as e:
            return f"GeoIP lookup failed: {str(e)}"

    # IP Intelligence Module
    def ip_intel(self, ip):
        """Comprehensive IP address investigation"""
        results = {
            'ip': ip,
            'reverse_dns': self.get_reverse_dns(ip),
            'whois': self.get_ip_whois(ip),
            'shodan': {} if not self.api_keys['shodan'] else self.shodan_lookup(ip),
            'geoip': self.get_ip_geo(ip),
            'ports': self.common_port_scan(ip)
        }
        return results

    def get_reverse_dns(self, ip):
        """Perform reverse DNS lookup"""
        try:
            return socket.gethostbyaddr(ip)[0]
        except:
            return "Not found"

    def get_ip_whois(self, ip):
        """Retrieve IP WHOIS information"""
        try:
            obj = IPWhois(ip)
            return obj.lookup_rdap()
        except Exception as e:
            return f"IP WHOIS lookup failed: {str(e)}"

    def shodan_lookup(self, ip):
        """Query Shodan for IP information"""
        try:
            api = shodan.Shodan(self.api_keys['shodan'])
            return api.host(ip)
        except Exception as e:
            return f"Shodan lookup failed: {str(e)}"

    def get_ip_geo(self, ip):
        """Get geolocation for IP"""
        try:
            response = requests.get(f"http://ip-api.com/json/{ip}", timeout=5)
            return response.json()
        except:
            return "Geolocation lookup failed"

    def common_port_scan(self, ip):
        """Quick port scan of common services"""
        common_ports = [21, 22, 80, 443, 3306, 3389]
        results = {}
        
        def check_port(port):
            try:
                with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
                    s.settimeout(1)
                    s.connect((ip, port))
                    results[port] = "open"
            except:
                results[port] = "closed/filtered"
                
        with ThreadPoolExecutor(max_workers=10) as executor:
            executor.map(check_port, common_ports)
            
        return results

    # Email Intelligence Module
    def email_intel(self, email):
        """Investigate email address"""
        results = {
            'email': email,
            'breaches': self.check_breaches(email),
            'social_media': self.find_social_profiles(email),
            'domain_info': self.domain_intel(email.split('@')[-1]) if '@' in email else None
        }
        return results

    def check_breaches(self, email):
        """Check if email appears in breaches (using HaveIBeenPwned API pattern)"""
        try:
            if not self.api_keys['virustotal']:
                return "Virustotal API key required"
                
            headers = {"x-apikey": self.api_keys['virustotal']}
            response = requests.get(
                f"https://www.virustotal.com/api/v3/domains/{email}",
                headers=headers
            )
            return response.json()
        except Exception as e:
            return f"Breach check failed: {str(e)}"

    def find_social_profiles(self, email):
        """Search for social media profiles (simulated)"""
        # Note: Actual implementation would require proper API integration
        return {
            'status': 'simulated_results',
            'profiles': ['twitter', 'linkedin', 'github']
        }

    # Website/HTTP Intelligence Module
    def get_http_headers(self, domain):
        """Retrieve HTTP headers"""
        try:
            response = requests.get(f"http://{domain}", timeout=5)
            return dict(response.headers)
        except:
            try:
                response = requests.get(f"https://{domain}", timeout=5)
                return dict(response.headers)
            except Exception as e:
                return f"HTTP headers retrieval failed: {str(e)}"

    def detect_technologies(self, domain):
        """Detect web technologies (simplified)"""
        try:
            response = requests.get(f"https://{domain}", timeout=5)
            tech = []
            
            # Simple detection patterns
            if 'X-Powered-By' in response.headers:
                tech.append(response.headers['X-Powered-By'])
                
            if 'server' in response.headers:
                tech.append(f"Server: {response.headers['server']}")
                
            if 'wp-content' in response.text:
                tech.append('WordPress')
                
            return tech
        except:
            return "Technology detection failed"

    def check_security_headers(self, domain):
        """Check for important security headers"""
        headers = self.get_http_headers(domain)
        if isinstance(headers, str):
            return headers
            
        security_headers = [
            'Content-Security-Policy',
            'X-Frame-Options',
            'X-Content-Type-Options',
            'Strict-Transport-Security',
            'Referrer-Policy'
        ]
        
        results = {}
        for header in security_headers:
            results[header] = headers.get(header, 'MISSING')
            
        return results

    def virustotal_scan(self, domain):
        """Scan domain with VirusTotal"""
        try:
            headers = {"x-apikey": self.api_keys['virustotal']}
            response = requests.get(
                f"https://www.virustotal.com/api/v3/domains/{domain}",
                headers=headers
            )
            return response.json()
        except Exception as e:
            return f"VirusTotal scan failed: {str(e)}"

    # Main Execution
    def run(self, args):
        """Execute the requested OSINT operation"""
        print(self.banner)
        print(f"Version: {self.version} | {self.author}\n")
        
        results = {}
        
        if args.module == 'domain':
            results = self.domain_intel(args.target)
        elif args.module == 'ip':
            results = self.ip_intel(args.target)
        elif args.module == 'email':
            results = self.email_intel(args.target)
        elif args.module == 'full':
            # Try to determine target type automatically
            if re.match(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$', args.target):
                results = self.ip_intel(args.target)
            elif '@' in args.target:
                results = self.email_intel(args.target)
            else:
                # Assume domain
                results = self.domain_intel(args.target)
        
        if args.output:
            with open(args.output, 'w') as f:
                json.dump(results, f, indent=2, default=str)
            print(f"\n[+] Results saved to {args.output}")
        else:
            print("\n[+] Investigation Results:")
            print(json.dumps(results, indent=2, default=str))

def main():
    parser = argparse.ArgumentParser(description='Ultimate OSINT Tool - Comprehensive Open-Source Intelligence Gathering')
    parser.add_argument('-m', '--module', required=True,
                       choices=['domain', 'ip', 'email', 'full'],
                       help='Intelligence module to use')
    parser.add_argument('-t', '--target', required=True,
                       help='Target to investigate (domain, IP, or email)')
    parser.add_argument('-o', '--output',
                       help='Output file (JSON format)')
    
    args = parser.parse_args()
    tool = OSINTTool()
    
    try:
        tool.run(args)
    except KeyboardInterrupt:
        print("\n[!] Scan interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n[!] Error: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()