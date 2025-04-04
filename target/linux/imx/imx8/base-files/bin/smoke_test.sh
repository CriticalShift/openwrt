#!/bin/sh

# OpenWRT image smoke test script
# Performs basic peripheral and driver tests, but may not actually test full functionality
# such as data movement and integrity as that usually requires some coordination with an
# outside system.
#!/bin/sh

# --- Configuration ---
LOG_FILE="test_run.log"
# Use tput for wider terminal compatibility, fallback if not found
if command -v tput >/dev/null 2>&1; then
    GREEN=$(tput setaf 2)
    RED=$(tput setaf 1)
    RESET=$(tput sgr0)
else
    # Standard ANSI escape codes as fallback
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    RESET='\033[0m'
fi

# --- Framework Functions ---

# Clears the log file at the start
setup_test_env() {
    echo "Starting Test Run: $(date)" > "$LOG_FILE"
    echo "==========================================" >> "$LOG_FILE"
    echo "Test log available at: $LOG_FILE"
    echo "" # Newline for cleaner console output
}

# Logs a command being run and its output
log_command_output() {
    local description="$1"
    local command_output="$2"
    echo "--- [LOG] $description ---" >> "$LOG_FILE"
    echo "$command_output" >> "$LOG_FILE"
    echo "--- [END LOG] ---" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE" # Add spacing in log file
}

# Prints the test group header
start_group() {
    local group_name="$1"
    echo "$group_name" # Print to console
    echo "\n# Test Group: $group_name" >> "$LOG_FILE" # Log group start
}

# Runs an individual test check
# Arguments:
#   $1: Test description string (e.g., "Checking for XYZ")
#   $2: The captured command output string to search within
#   $3: The pattern string to grep for
run_grep_test() {
    local description="$1"
    local content_to_check="$2"
    local pattern_to_find="$3"
    local result_str
    local color_code

    # Print description part to console (no newline yet)
    printf -- "- %s... " "$description"

    # Perform the check silently using grep -q
    # The exit status of grep -q is 0 if found, non-zero otherwise
    echo "$content_to_check" | grep -q -P "$pattern_to_find"
    local exit_status=$?

    # Determine result and color
    if [ $exit_status -eq 0 ]; then
        result_str="PASS"
        color_code="$GREEN"
    else
        result_str="FAIL"
        color_code="$RED"
    fi

    # Print result with color and newline to console
    # printf "%s%s%s\n" "$color_code" "$result_str" "$RESET"
    printf "%s\n" "$result_str"

    # Log test result
    echo "  - Test: $description ... $result_str" >> "$LOG_FILE"
}

# Arguments:
#   $1: Test description string (e.g., "Checking for XYZ")
#   $2: The captured command output string to check to see if there's any output
run_str_test() {
    local description="$1"
    local content_to_check="$2"
    local result_str
    local color_code

    # Print description part to console (no newline yet)
    printf -- "- %s... " "$description"

    # Check if the string is empty or only contains whitespace
    if [ -n "$(echo "$content_to_check" | tr -d '[:space:]')" ]; then
        result_str="PASS"
        color_code="$GREEN"
    else
        result_str="FAIL"
        color_code="$RED"
    fi

    # Print result with color and newline to console
    # printf "%s%s%s\n" "$color_code" "$result_str" "$RESET"
    printf "%s\n" "$result_str"

    # Log test result
    echo "  - Test: $description ... $result_str" >> "$LOG_FILE"
}

# Arguments:
#   $1: Test description string (e.g., "Checking for XYZ")
#   $2: The file or directory to check if it exists
run_fstat_test() {
    local description="$1"
    local path_to_check="$2"
    local result_str
    local color_code

    # Print description part to console (no newline yet)
    printf -- "- %s... " "$description"

    # Check if the file/directory exists
    if [ -e "$path_to_check" ]; then
        result_str="PASS"
        color_code="$GREEN"
    else
        result_str="FAIL"
        color_code="$RED"
    fi

    # Print result with color and newline to console
    #printf "%s%s%s\n" "$color_code" "$result_str" "$RESET"
    printf "%s\n" "$result_str"

    # Log test result
    echo "  - Test: $description ... $result_str" >> "$LOG_FILE"
}

# --- Test Group Definitions ---

test_group_wifi() {
    start_group "Performing Wi-Fi checks:"

    # --- Capture Data ---
    local dmesg_output=$(dmesg | grep -i mmc1 2>&1) # Capture both stdout and stderr
    log_command_output "dmesg output" "$dmesg_output"

    local lsmod_output=$(lsmod | grep -i moal 2>&1)
    log_command_output "lsmod output" "$lsmod_output"

    # --- Run Tests ---
    run_grep_test "Checking for MMC controller" "$dmesg_output" "mmc1: SDHCI controller"
    run_grep_test "Checking for MMC card" "$dmesg_output" "mmc1: new high speed SDIO card"
    run_grep_test "Checking for Wi-Fi driver" "$lsmod_output" "moal\s+[0-9]+\s+1"
    run_fstat_test "Checking Wi-Fi firmware" "/lib/firmware/nxp/sd_w61x_v1.bin.se"
    run_fstat_test "Checking Wi-Fi driver config" "/lib/firmware/nxp/wifi_mod_para.conf"

    echo ""
}

test_group_cellular() {
    start_group "Performing Cellular checks:"

    # --- Capture Data ---
    local lsusb_output=$(lsusb 2>&1)
    log_command_output "lsusb output" "$lsusb_output"

    # # Example: Capture ip addr show output
    # local ip_addr_output
    # ip_addr_output=$(ip addr show 2>&1)
    # log_command_output "ip addr show output" "$ip_addr_output"

    # # Example: Capture UCI network config for WAN zone
    # local uci_wan_output
    # # Note: Adjust 'wan' if your zone name is different
    # uci_wan_output=$(uci show network | grep ".zone='wan'" 2>&1)
    # log_command_output "UCI WAN zone interfaces" "$uci_wan_output"


    # --- Run Tests ---
    run_grep_test "Checking for Sierra USB device" "$lsusb_output" "Sierra Wireless"
    run_fstat_test "Checking for CDC device interface" "/dev/cdc-wdm0"
    run_fstat_test "Checking for USB control interface 1" "/dev/ttyUSB0"
    run_fstat_test "Checking for USB control interface 2" "/devttyUSB1"
    run_fstat_test "Checking for USB control interface 3" "/dev/ttyUSB2"

    echo ""
}

test_group_eth0() {
    start_group "Performing ETH0 (VSC) checks:"

    # --- Capture Data ---

    # --- Run Tests ---

}

test_group_eth1() {
    start_group "Performing ETH1 (Realtek) checks:"

    # --- Capture Data ---

    # --- Run Tests ---
}

# --- Main Execution ---

setup_test_env

# Add calls to all your test group functions here
test_group_wifi
test_group_cellular
# test_group_another_subsystem
# ... etc ...

echo "Test run complete. Check '$LOG_FILE' for detailed command output."

exit 0 # Exit with success code (framework ran successfully)

echo "Ethernet:"
dmesg | grep -i "eth0"
dmesg | grep -i "eth1"

echo ""
echo "SDIO/Wi-Fi:"
dmesg | grep -i "30b50000.mmc"
lsmod | grep -E "mlan|moal"

echo ""
echo "Cell/USB:"
lsusb
ls /dev/ttyU*

echo ""
echo "Dumping NIC status:"
ip address
