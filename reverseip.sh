#!/usr/bin/env bash

# code by DAN MAFFIA 

figlet "DAN"
figlet "MAFFIA"
echo "

                  ⡞⠉⠊⢱ ⣀⣀
               ⣰⠏⠑⢷  ⡸⠋ ⠸⣄
              ⠘⢅⡀  ⡷⠒⢧⣀⣀⡤⠊
               ⣠⠞⠛⠉⢇⣀⣸⠁ ⠉⠳⡄
               ⠓⡄ ⣠⡎ ⠈⢧⣄⣠⠎
                ⠑⠊⠁⣇⣀⡀⡸
              ⣀⣀⣀⣀  ⠘⡆
              ⢟⠲⢄⡀⠉⠲⡄⡇
              ⠈⠣⡀⠈⠓⢤⡈⣧
                ⠈⠓⠢⠤⠬⢿⡀
                      ⡇
                      ⢸⡀
                       ⢇
                        ⢘⠄

                  R E V E R S E
                       I P
  Unlimited, fast, and easy Reverse IP Lookup
"
figlet "CODING"
figlet "FAMILY"
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: reverseip.sh -d [domain] -v [version] -o [output]"
    echo "Example: reverseip.sh -d example.com -v 1 -o reverseip.txt"
    echo
    exit 1
fi

if ! [ -x "$(command -v jq)" ]; then
    echo "Error: jq is not installed." >&2
    read -p "Would you like to install jq? [y/n] " -n 1 -r installjq
    echo
    if [[ $installjq =~ ^[Yy]$ ]]
    then
        echo "Installing jq..."
        if [ -x "$(command -v apt)" ]; then
            sudo apt install jq
            elif [ -x "$(command -v dnf)" ]; then
            sudo dnf install jq
            elif [ -x "$(command -v pacman)" ]; then
            sudo pacman -S jq
            elif [ -x "$(command -v brew)" ]; then
            brew install jq
            elif [ -x "$(command -v pkg)" ]; then
            pkg install jq
        else
            echo "Error: Package manager not found." >&2
            exit 1
        fi
    else
        echo "Exiting..."
        exit 1
    fi
fi

if ! [ -x "$(command -v curl)" ]; then
    echo "Error: curl is not installed." >&2
    read -p "Would you like to install curl? [y/n] " -n 1 -r installcurl
    echo
    if [[ $installcurl =~ ^[Yy]$ ]]
    then
        echo "Installing curl..."
        if [ -x "$(command -v apt)" ]; then
            sudo apt install curl
            elif [ -x "$(command -v dnf)" ]; then
            sudo dnf install curl
            elif [ -x "$(command -v pacman)" ]; then
            sudo pacman -S curl
            elif [ -x "$(command -v brew)" ]; then
            brew install curl
            elif [ -x "$(command -v pkg)" ]; then
            pkg install curl
        else
            echo "Error: Package manager not found." >&2
            exit 1
        fi
    else
        echo "Exiting..."
        exit 1
    fi
fi

function remove_protocol() {
    echo "$1" | sed -e 's/https\?:\/\///'
}

# Credit to https://stackoverflow.com/a/23676680
function valid_ip()
{
    local  IPA1=$1
    local  stat=1
    
    if [[ $IPA1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]];
    then
        OIFS=$IFS 
        IFS='.'   
        ip=($ip)  
        IFS=$OIFS
        
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]  
        
        stat=$? 
        
    fi 
    
    return $stat 
}

if [[ "$1" == "-d" ]]; then
    if [[ -z "$2" ]]; then
        echo "Error: No URL/IP" >&2
        exit 1
    fi
    if valid_ip "$2"; then
        input="$2"
    else
        input=$(remove_protocol "$2")
    fi
    if [[ "$3" == "-v" ]]; then
        if [[ "$4" == "1" ]]; then
            version="1"
            elif [[ "$4" == "2" ]]; then
            version="2"
            elif [[ "$4" == "3" ]]; then
            version="3"
            elif [[ "$4" == "4" ]]; then
            version="4"
        else
            echo "Error: -v flag must be 1, 2, 3, or 4" >&2
            exit 1
        fi
    else
        version="1"
    fi
    
    if [[ "$5" == "-o" ]]; then
        output="$6"
        if [[ "$output" != *.txt ]]; then
            output="$output.txt"
        fi
    elif [[ "$3" == "-o" ]]; then
        output="$4"
        if [[ "$output" != *.txt ]]; then
            output="$output.txt"
        fi
    else
        output="reverseip_$(shuf -i 100000-999999 -n 1).txt"
    fi
else
    read -p "Website URL/IP  : " input
    if [[ -z "$input" ]]; then
        echo "Error: No URL/IP" >&2
        exit 1
    fi
    if valid_ip "$input"; then
        input="$input"
    else
        input=$(remove_protocol "$input")
    fi
    read -p "Version 1/2/3/4  : " version
    if [[ -z "$output" ]]; then
        version="1"
    elif [[ "$version" > 4 ]]; then
        echo "Error: Version must be 1, 2, 3, or 4" >&2
        exit 1
    fi
    read -p "Output file    : " output
    if [[ -z "$output" ]]; then
        output="tulips_$(shuf -i 100000-999999 -n 1).txt"
    elif [[ "$output" != *.txt ]]; then
        output="$output.txt"
    fi
fi

curl -s "https://reverseip.rei.my.id/api?v$version=$input" | jq -r '.listDomain[]' > $output

echo "Done! Results saved as $output"
read -p "Would you like to open the file? [y/n] " -n 1 -r openfile
echo
if [[ $openfile =~ ^[Yy]$ ]]; then
    cat $output
fi