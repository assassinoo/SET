# Subdomain Enumeration Tool (SET)

Developer: Marton Andrei
Overview:
SET is a comprehensive subdomain enumeration and reconnaissance tool designed to assist penetration testers and cybersecurity professionals in their network assessments. The tool integrates multiple well-known utilities to fetch, analyze, and visualize potential attack vectors in a target domain.

# Features:

Harvests subdomains using assetfinder.
Probes for alive domains with httprobe.
Checks for potential subdomain takeovers with subjack.
Scans for open ports using nmap.
Scrapes wayback data via waybackurls.
Captures screenshots of live domains with gowitness.

Usage:

./set.sh <target_domain>
Upon execution, users can select which tools to run, providing a customizable experience tailored to the user's needs.

Note:
Always ensure that you have the proper authorization to scan and probe the target. Unauthorized scanning and data collection is illegal and can lead to severe consequences.

Contributions & Feedback:
This tool is maintained by Marton Andrei. For any feedback, suggestions, or contributions, please reach out.
