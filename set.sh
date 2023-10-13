#!/bin/bash

clear

echo "-----------------------------------"
echo "  SUBDOMAIN ENUMERATION TOOL       "
echo "  Developed by: Marton Andrei      "
echo "-----------------------------------"
echo "Please use responsibly and ensure permissions."
echo "Misuse can lead to legal consequences!"
echo ""

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1 || { echo >&2 "Error: $1 is not installed."; exit 1; }
}

# Check if a domain or URL was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <target>"
    exit 1
fi

url="$1"

# Ask the user which tools to use
echo "Select the tools you want to use:"
read -p "Use assetfinder? (y/n): " use_assetfinder
read -p "Use httprobe? (y/n): " use_httprobe
read -p "Use subjack? (y/n): " use_subjack
read -p "Use nmap? (y/n): " use_nmap
read -p "Use waybackurls? (y/n): " use_waybackurls
read -p "Use gowitness for screenshotting? (y/n): " use_gowitness

# Check if the required tools are installed before running them
[[ $use_assetfinder == 'y' ]] && command_exists assetfinder
[[ $use_httprobe == 'y' ]] && command_exists httprobe
[[ $use_subjack == 'y' ]] && command_exists subjack
[[ $use_nmap == 'y' ]] && command_exists nmap
[[ $use_waybackurls == 'y' ]] && command_exists waybackurls
[[ $use_gowitness == 'y' ]] && command_exists gowitness

# Create necessary directories and files
declare -a dirs=(
    "$url/recon"
    "$url/recon/scans"
    "$url/recon/httprobe"
    "$url/recon/potential_takeovers"
    "$url/recon/wayback"
    "$url/recon/wayback/params"
    "$url/recon/wayback/extensions"
    "$url/recon/gowitness"
)

for dir in "${dirs[@]}"; do
    [ -d "$dir" ] || mkdir -p "$dir"
done

declare -a files=(
    "$url/recon/httprobe/alive.txt"
    "$url/recon/final.txt"
)

for file in "${files[@]}"; do
    [ -f "$file" ] || touch "$file"
done

# Run the tools based on user input
if [[ $use_assetfinder == 'y' ]]; then
    echo "[+] Harvesting subdomains with assetfinder..."
    assetfinder $url >> $url/recon/final.txt
fi

if [[ $use_httprobe == 'y' ]]; then
    echo "[+] Probing for alive domains..."
    cat $url/recon/final.txt | httprobe -s -p https:443 | sed 's/https\?:\/\///' | tr -d ':443' >> $url/recon/httprobe/alive.txt
fi

if [[ $use_subjack == 'y' ]]; then
    echo "[+] Checking for possible subdomain takeover..."
    subjack -w $url/recon/final.txt -t 100 -timeout 30 -ssl -c /opt/subjack/fingerprints.json -v 3 -o $url/recon/potential_takeovers/potential_takeovers.txt
fi

if [[ $use_nmap == 'y' ]]; then
    echo "[+] Scanning for open ports..."
    nmap -iL $url/recon/httprobe/alive.txt -T4 -oA $url/recon/scans/scanned.txt
fi

if [[ $use_waybackurls == 'y' ]]; then
    echo "[+] Scraping wayback data..."
    cat $url/recon/final.txt | waybackurls >> $url/recon/wayback/wayback_output.txt
    sort -u $url/recon/wayback/wayback_output.txt -o $url/recon/wayback/wayback_output.txt

    # Extracting parameters and extensions
    grep '?*=' $url/recon/wayback/wayback_output.txt | cut -d '=' -f 1 | sort -u >> $url/recon/wayback/params/wayback_params.txt
    for ext in js html json php aspx; do
        grep "\.$ext$" $url/recon/wayback/wayback_output.txt | sort -u >> $url/recon/wayback/extensions/$ext.txt
    done
fi

if [[ $use_gowitness == 'y' ]]; then
    echo "[+] Taking screenshots of alive domains with gowitness..."
    
    while read -r domain; do
        gowitness single "https://$domain" --screenshot-path=$url/recon/gowitness || { echo "Error: Failed to capture screenshot for $domain"; }
        sleep 2
    done < $url/recon/httprobe/alive.txt
fi

echo "[+] Enumeration completed! Check the recon directory for results."
