#!/bin/bash

# Prompt for contract name
read -p "Enter the contract name: " contract_name

# Prompt for output file path
read -p "Enter the output file path: " output_file

# Prompt for Solidity pragma version
read -p "Enter the Solidity pragma version (e.g., 0.8.20): " pragma_version

# Prompt for the License
read -p "Enter the License (e.g., MIT): " license

# Ensure the directory exists
output_dir=$(dirname "$output_file")
mkdir -p "$output_dir"

# Write the output to the output file
echo "//SPDX-License-Identifier: ${license}" > "$output_file"
echo "" >> "$output_file"
echo "pragma solidity ^${pragma_version};" >> "$output_file"
echo "contract ${contract_name} {" >> "$output_file"
echo "    // Contract body goes here" >> "$output_file"
echo "}" >> "$output_file"

echo "Solidity contract file created: $output_file"
echo "Contract Name: $contract_name"
echo "Pragma Version: $pragma_version"