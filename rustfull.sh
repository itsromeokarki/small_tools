#!/bin/bash

# Function to display help information
show_help() {
    echo "Usage: rustfull [OPTION]..."
    echo "Process a file containing IP addresses and port lists, and output them in IP:port format."
    echo
    echo "Options:"
    echo "  -h, --help       Show this help message and exit"
    echo "  -v, --version    Show version information and exit"
    echo
    echo "Examples:"
    echo "  cat file.txt | rustfull       Process the input from file.txt"
    echo "  rustfull --help               Show this help message"
    echo "  rustfull --version            Show version information"
}

# Function to display version information
show_version() {
    echo "rustfull version 1.0.0"
}

# Function to process each line
process_line() {
    local line="$1"
    
    # Extract IP and ports using `awk`
    local ip=$(echo "$line" | awk -F ' -> ' '{print $1}')
    local ports_str=$(echo "$line" | awk -F ' -> ' '{print $2}' | sed 's/[][]//g')
    
    # Convert comma-separated ports into individual lines
    echo "$ports_str" | tr ',' '\n' | while read -r port; do
        echo "$ip:$port"
    done
}

# Check for help or version options
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_help
    exit 0
elif [[ "$1" == "--version" || "$1" == "-v" ]]; then
    show_version
    exit 0
elif [[ $# -eq 0 ]]; then
    # No arguments provided, process stdin
    while IFS= read -r line; do
        process_line "$line"
    done
    exit 0
else
    # Handle invalid options
    echo "Error: Invalid option '$1'. Use --help or -h for usage information."
    exit 1
fi
