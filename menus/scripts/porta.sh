#!/usr/bin/env bash
GREEN='\033[0;32m'  # Green
RED='\033[0;31m'    # Red
NC='\033[0m'        # No Color (reset to default)
YELLOW="\e[0;33m"
BLUE="\e[0;34m"

# check if the user provide 3 arguments 
if [[ $# -ne 3 ]]; then
    echo -e "${YELLOW}Uso: porta.sh <targetip> <startingport> <endingport>${NC}"
    exit 1
fi

# global array for open ports
result_array=()

# user press Ctrl+C the script will stop
function handle_interrupt() {
    if [[ ${#result_array[@]} -ne 0 ]]; then
        echo ""
        echo -e "${YELLOW}Discovered Open Ports before exit:${NC}\n"
        printf "%b\n" "${result_array[@]}"
    fi
    echo ""
    echo -e "${RED}\nKeyboard interrupt (Ctrl+C) detected. Exiting the script...${NC}"
    exit 1
}

trap handle_interrupt SIGINT

display_banner() {
    clear
    echo -e "${GREEN}"
    cat << "EOF" 

  _____  _______  _____   ______  _____ 
 |     | |______ |_____] |_____/ |     |
 |_____| ______| |       |    \_ |_____|
                                        
                    Developer: OnixSat

EOF
    echo -e "${NC}${YELLOW}* GitHub: https://github.com/onixsat${NC}\n"
}

scanner() {
    ipaddress=$1
    startingport=$2
    endingport=$3

    echo -e "${BLUE}Scanning ports ${startingport} to ${endingport} on host ${ipaddress} ${NC}\n"

    for (( port=startingport; port<=endingport; port++ )); do
        timeout 2 bash -c "echo > /dev/tcp/$ipaddress/$port" &>/dev/null
        if [[ $? -eq 0 ]]; then
            echo -e "$GREEN port $port is open at host $ipaddress $NC"
            result_array+=("port $port is open at host $ipaddress")
        else
            echo -e "$RED port $port is closed at host $ipaddress $NC"
        fi
    done

    echo ""

    # print the discovered open ports
    if [[ ${#result_array[@]} -ne 0 ]]; then
        echo -e "${YELLOW}Discovered Open Ports:${NC}\n"
        printf "%b\n" "${result_array[@]}"

        # save to file
        logfile="scan_results_$(date +%F_%H-%M-%S).txt"
        printf "%s\n" "${result_array[@]}" > "$logfile"
        echo -e "\n${BLUE}Results saved to $logfile${NC}"
    else
        echo -e "${RED}No open ports found.${NC}"
    fi
}
display_banner
scanner "$1" "$2" "$3"