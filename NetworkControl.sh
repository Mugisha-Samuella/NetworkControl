#!/bin/bash
# Author: Mugisha samuella
# Code: s23 - Network Research Automation
# unit: RW-CODING-ACADEMY-||
# Guide: Celestin NZEYIMANA

# tools installations and anonymity checking
tools_installation() {
    # required tools
    tools=("nmap" "whois" "tor" "sshpass" "proxychains4" "curl")

    echo "Checking for required tools..."
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            echo "$tool is not installed. Installing.."
            sudo apt update
            sudo apt install -y "$tool"
        else
            echo "$tool is installed."
        fi
    done
}

anonymity_checking() {
    echo "Starting Tor service"
    sudo service tor start

    echo "using ProxyChains to check if the connection is anonymous"
    # using proxychains together with curl to check IP address through Tor
    proxychains4 curl -s https://ipinfo.io/ip > anon_check.txt
    spoofedIp=$(<anon_check.txt)
    
    if [ -n "$spoofedIp" ]; then
        echo "Anonymity is now activated. Current IP through Tor: $spoofedIp"
    else
        echo "Failed to verify anonymity. Exiting script."
        exit 1
    fi
}

getting_target() {
    read -p "Enter the IP/domain address to scan: " target
    echo "$target"
}

# SSH to remote Server and Run Cmds

executing_remote_cmds() {
    local remoteIp="10.11.74.168"
    local username="user"
    local password="rca"
    local target="10.1.74.166"

    echo "Connecting to the remote server"

    # show server details country, IP, uptime
    echo "Retrieving server details"
    sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$username@$remoteIp" "uname -a && uptime"

    # running Whois on the target address
    echo "Running Whois on target address"
    whois_result=$(sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$username@$remoteIp" "whois $target")
    echo "$whois_result"
    echo "$whois_result" > whois_result.txt

    # running Nmap on the target address
    echo "Running Nmap scan on target address"
    nmap_result=$(sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$username@$remoteIp" "nmap -sS $target")
    echo "$nmap_result"
    echo "$nmap_result" > nmap_result.txt

    echo "Results saved to whois_result.txt and nmap_result.txt."
}


# tools installation
tools_installation

# anonimity checking
anonymity_checking

# getting the target address from the user
target=$(getting_target)

#remote server details
remoteIp="10.11.72.254"   
username="iceman"         
password="123"         

# connecting to the remote server, executing commands
executing_remote_cmds "$remoteIp" "$username" "$password" "$target"
