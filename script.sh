#!/bin/bash

# Color codes
YELLOW='\033[1;33m'
RED='\e[31m'
GREEN='\e[32m'
CYAN='\033[1;36m'
BLUE='\e[34m'
RESET='\e[0m'

# Function to display help
show_help() {
    echo -e "\nUsage: $0 [options]"
    echo -e "\nOptions:"
    echo -e "  -c, --config <config_file>  Specify the YAML configuration file."
    echo -e "  -list,  Show SSH sessions."
    echo -e "  -h, --help                   Display this help message."
}

# Default values
CONFIG_FILE="config.yaml"
#SSH_ARG_EXTRA_DEFAULT='-o BatchMode=yes -o ConnectTimeout=2 -o StrictHostKeyChecking=no -o HostKeyAlgorithms=ssh-rsa -o PubkeyAcceptedKeyTypes=ssh-rsa -o PasswordAuthentication=no'
SLAVE_NODES=()


# Read slave nodes from the YAML file
#SLAVE_NODES=($(${PWD}/binary/./yq eval '.slave_nodes[]' "$CONFIG_FILE"))
SLAVE_NODES=($(sed -n '/^compute_nodes:/,/^[^ ]/{/^  - /s/^  - //p}' "$CONFIG_FILE"))

# Check if nodes are set
if [ ${#SLAVE_NODES[@]} -eq 0 ]; then
    echo -e "${RED}Error: No slave nodes specified in the config file.${RESET}"
    exit 1
fi


# Function to check the status of a node
check_node() {
    NODE=$1
    if ssh -o BatchMode=yes -o ConnectTimeout=2 -o StrictHostKeyChecking=no -o PasswordAuthentication=no "${NODE}" "touch ~/FROM_MASTER.txt" &>/dev/null; then
        echo -e "└──$NODE: ${GREEN}Successfully Exec${RESET}"  # Green for ONLINE
    fi
}
run(){
    # Check each node and show progress
    #echo -e "\n${BLUE}Checking SSH connectivity to slave nodes...${RESET}"
    echo -e "${CYAN}${HOSTNAME}${RESET}[${YELLOW}captured logins${RESET}]"
    for NODE in "${SLAVE_NODES[@]}"; do
        check_node "$NODE" &
    done
    # Wait for all background jobs to finish
    wait
}

#echo -e "${BLUE}SSH connectivity check completed.${RESET}"
# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -c|--config) CONFIG_FILE="$2"; shift;; # [[ ! -z $CONFIG_FILE ]] && shift || echo -e "${RED}Error: config.yaml file required";exit 1;;
        -list) run;;
        -h|--help) show_help; exit 0 ;;
        *) echo -e "${RED}Error: Unknown parameter passed: $1${RESET}"; show_help; exit 1 ;;
    esac
    shift
done
