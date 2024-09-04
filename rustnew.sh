#!/bin/bash

# Function to display help information
show_help() {
    cat << EOF
Usage: $0 [OPTIONS] <nmapreadyipsmain> <name>

A script to process IP addresses through various stages of scanning and filtering.

Options:
  -h, --help        Show this help message and exit.

Arguments:
  nmapreadyipsmain  File containing the main list of IPs ready for nmap scanning.
  name              Name for temporary files and output directories.

Description:
  This script performs the following steps:
  1. Cleans the Cloudflare IPs using `cf-check`.
  2. Filters the IPs using `rustscan` and `gf`.
  3. Combines the results to remove error IPs.
  4. Runs a final scan using `rustscan` and outputs the results.

Dependencies:
  - cf-check
  - rustscan
  - gf
  - combine

EOF
}

# Check for help option
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# Validate input
if [ "$#" -ne 2 ]; then
    echo "Error: Invalid number of arguments."
    show_help
    exit 1
fi

nmapreadyipsmain="$1"
nmapreadyips="/tmp/herozallready-$2"
name="$2"
erorrips="/tmp/herzonrserrorips$2"
nmapreadyips2="/tmp/herzonfinalip$2"

echo "Clearing the cf IPs"
cat "$nmapreadyipsmain" | cf-check | tee "$nmapreadyips"
cat "$nmapreadyips"

echo "Filtering the IPs"
rustscan -a "$nmapreadyips" -r 1-5 -g | gf ip-grep | tee "$erorrips"
cat "$erorrips"

combine "$nmapreadyips" not "$erorrips" | tee "$nmapreadyips2"

echo "Starting the final scan"
rustscan -a "$nmapreadyips2" -u 15000  -g | tee "$HOME/tomatobuster/output/$2/final_output/scannedips"
