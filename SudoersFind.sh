#!/bin/bash

cat << "EOF"
   
░██████╗██╗░░░██╗██████╗░░█████╗░███████╗██████╗░░██████╗  ███████╗██╗███╗░░██╗██████╗░
██╔════╝██║░░░██║██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔════╝  ██╔════╝██║████╗░██║██╔══██╗
╚█████╗░██║░░░██║██║░░██║██║░░██║█████╗░░██████╔╝╚█████╗░  █████╗░░██║██╔██╗██║██║░░██║
░╚═══██╗██║░░░██║██║░░██║██║░░██║██╔══╝░░██╔══██╗░╚═══██╗  ██╔══╝░░██║██║╚████║██║░░██║
██████╔╝╚██████╔╝██████╔╝╚█████╔╝███████╗██║░░██║██████╔╝  ██║░░░░░██║██║░╚███║██████╔╝
╚═════╝░░╚═════╝░╚═════╝░░╚════╝░╚══════╝╚═╝░░╚═╝╚═════╝░  ╚═╝░░░░░╚═╝╚═╝░░╚══╝╚═════╝░                 
        SUID / SGID Scanner + GTFOBins Checker
EOF

echo
echo "| Searching for binaries with SUID and SGID |"
echo

echo "| Binaries with SUID (execute as file owner) |"
find / -type f -perm -4000 -exec ls -l {} 2>/dev/null | tee suid_binaries.txt

echo
echo "| Binaries with SGID (execute as file group) |"
find / -type f -perm -2000 -exec ls -l {} 2>/dev/null | tee sgid_binaries.txt

echo
echo "| Checking common binaries for SUID/SGID and privilege escalation potential |"
echo

binaries=(
    "bash" "sh" "dash" "zsh"
    "python" "python3" "perl" "ruby" "lua" "php"
    "vim" "vi" "nano" "less" "more" "man"
    "find" "awk" "sed" "env" "xargs"
    "nmap" "tcpdump" "curl" "wget" "nc" "netcat" "ftp" "telnet"
    "cp" "mv" "tar" "gzip" "gunzip" "xz" "unzip" "zip"
    "passwd" "su" "sudo" "chsh" "newgrp" "pkexec" "doas" "mount" "umount" "crontab" "at"
    "gcc" "g++" "cc" "make" "base64" "xxd" "openssl"
)

for bin in "${binaries[@]}"; do
    path=$(command -v "$bin" 2>/dev/null)
    if [[ -n $path ]]; then
        perms=$(ls -l "$path" 2>/dev/null)
        suid_flag=$(find "$path" -perm -4000 2>/dev/null)
        sgid_flag=$(find "$path" -perm -2000 2>/dev/null)
        echo "$perms"
        if [[ -n $suid_flag ]]; then
            echo "  -> SUID bit is set."
        fi
        if [[ -n $sgid_flag ]]; then
            echo "  -> SGID bit is set."
        fi
        echo
    fi
done

echo "|Checking for known GTFOBins present on the system |"
echo

gtfobins_list=(
    "bash" "cat" "chmod" "chown" "cp" "curl" "cut" "dash" "env" "find" "ftp" "gdb"
    "grep" "less" "lua" "man" "more" "mount" "mv" "nano" "nc" "nmap" "openssl"
    "perl" "php" "python" "python3" "readelf" "rsync" "scp" "sed" "sh" "socat"
    "ssh" "strace" "tar" "tcpdump" "tee" "telnet" "tftp" "time" "unzip" "vi"
    "vim" "wget" "xxd" "zip"
)

for bin in "${gtfobins_list[@]}"; do
    path=$(command -v "$bin" 2>/dev/null)
    if [[ -n $path ]]; then
        suid_flag=$(find "$path" -perm -4000 2>/dev/null)
        sgid_flag=$(find "$path" -perm -2000 2>/dev/null)
        echo "✔ $bin found at $path"
        if [[ -n $suid_flag || -n $sgid_flag ]]; then
            echo "  -> WARNING: $bin has elevated permissions and is in GTFOBins!"
            echo "     Check: https://gtfobins.github.io/gtfobins/$bin/"
        fi
    fi
done

echo
echo "| Scan complete |"
echo "Reports saved to suid_binaries.txt and sgid_binaries.txt"
