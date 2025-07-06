#!/bin/bash

# 🩸 LilithOS Initialization Suite - Diagnostic Crumbs Script
# 
# 📋 QUANTUM DOCUMENTATION:
# This script creates forged diagnostic panic reports (.diagpanic files) that
# appear to be legitimate system framework failures, creating a lie that becomes
# truth through the diagnostic reporting system.
# 
# 🧩 FEATURE CONTEXT:
# - Generates realistic .diagpanic files
# - Forges framework failure signatures
# - Integrates with macOS diagnostic system
# - Creates persistent diagnostic breadcrumbs
# 
# 🧷 DEPENDENCIES:
# - macOS 10.15+ (Catalina and later)
# - Root privileges for diagnostic directory access
# - ReportCrash daemon integration
# - Symbolication framework access
# 
# 💡 USAGE EXAMPLES:
#   ./diagnostic_crumbs.sh                  # Create diagnostic breadcrumbs
#   ./diagnostic_crumbs.sh --dry-run       # Test mode without creation
#   ./diagnostic_crumbs.sh --cleanup       # Remove diagnostic breadcrumbs
#   ./diagnostic_crumbs.sh --status        # Check breadcrumb status
# 
# ⚡ PERFORMANCE CONSIDERATIONS:
# - Minimal system impact during creation
# - Realistic timing and frequency
# - Proper diagnostic file formatting
# - Integration with existing diagnostic system
# 
# 🔒 SECURITY IMPLICATIONS:
# - Requires root privileges for diagnostic access
# - Creates forged system diagnostic reports
# - May be detected by diagnostic analysis tools
# - Could trigger system health monitoring
# 
# 📜 CHANGELOG:
# - 2024-01-XX: Initial implementation
# - Added comprehensive error handling
# - Implemented realistic diagnostic generation
# - Enhanced breadcrumb persistence

set -euo pipefail

# Configuration
SCRIPT_NAME="diagnostic_crumbs.sh"
LILITH_UUID="$(uuidgen)"
DIAGNOSTIC_DIR="/Library/Logs/DiagnosticReports"
BACKUP_DIR="/tmp/lilithos_backup_$(date +%Y%m%d_%H%M%S)"
LOG_FILE="/var/log/lilithos_diagnostic.log"
CRUMB_INTERVAL=3600  # 1 hour between breadcrumbs

# Framework names for forging failures
FRAMEWORKS=(
    "com.apple.framework.CoreFoundation"
    "com.apple.framework.Foundation"
    "com.apple.framework.AppKit"
    "com.apple.framework.Security"
    "com.apple.framework.SystemConfiguration"
    "com.apple.framework.CoreServices"
    "com.apple.framework.CoreGraphics"
    "com.apple.framework.CoreData"
    "com.apple.framework.CoreAnimation"
    "com.apple.framework.CoreLocation"
)

# Process names for realistic crashes
PROCESSES=(
    "WindowServer"
    "Dock"
    "Finder"
    "SystemUIServer"
    "loginwindow"
    "launchd"
    "kernel_task"
    "mds"
    "mdworker"
    "com.apple.WebKit.WebContent"
)

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Logging function with timestamp and color coding
log() {
    local level="$1"
    local message="$2"
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    
    case "$level" in
        "INFO")  echo -e "${GREEN}[INFO]${NC} $timestamp: $message" | tee -a "$LOG_FILE" ;;
        "WARN")  echo -e "${YELLOW}[WARN]${NC} $timestamp: $message" | tee -a "$LOG_FILE" ;;
        "ERROR") echo -e "${RED}[ERROR]${NC} $timestamp: $message" | tee -a "$LOG_FILE" ;;
        "DEBUG") echo -e "${BLUE}[DEBUG]${NC} $timestamp: $message" | tee -a "$LOG_FILE" ;;
        "RITUAL") echo -e "${PURPLE}[RITUAL]${NC} $timestamp: $message" | tee -a "$LOG_FILE" ;;
    esac
}

# Check if running as root
check_privileges() {
    if [[ $EUID -ne 0 ]]; then
        log "ERROR" "This script must be run as root for diagnostic directory access"
        exit 1
    fi
}

# Create backup directory
create_backup() {
    log "INFO" "Creating backup directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
}

# Generate realistic stack trace
generate_stack_trace() {
    local framework="${FRAMEWORKS[$((RANDOM % ${#FRAMEWORKS[@]}))]}"
    local process="${PROCESSES[$((RANDOM % ${#PROCESSES[@]}))]}"
    local crash_address=$(printf "0x%016x" $((0x7fff00000000 + RANDOM * 4096)))
    local frame_count=$((5 + RANDOM % 10))
    
    cat << EOF
Process:               $process [$(($(date +%s) - RANDOM % 86400))]
Path:                  /System/Library/CoreServices/$process
Identifier:            com.apple.$process
Version:               $(sw_vers -productVersion) ($(sw_vers -buildVersion))
Code Type:             X86-64 (Native)
Parent Process:        launchd [1]
Responsible:           $process [$(($(date +%s) - RANDOM % 86400))]
User ID:               501

Date/Time:             $(date '+%Y-%m-%d %H:%M:%S %z')
OS Version:            macOS $(sw_vers -productVersion) ($(sw_vers -buildVersion))
Report Version:        12
Anonymous UUID:        $LILITH_UUID

Crashed Thread:        $(($(date +%s) % 16))  Dispatch queue: com.apple.main-thread

Exception Type:        EXC_BAD_ACCESS (SIGSEGV)
Exception Codes:       KERN_INVALID_ADDRESS at $crash_address
Exception Note:        EXC_CORPSE_NOTIFY

Termination Reason:    Namespace SIGNAL, Code 11 Segmentation fault: 11
Terminating Process:   exc handler [0]

Thread $(($(date +%s) % 16)) Crashed:
EOF
    
    # Generate stack frames
    for ((i=0; i<frame_count; i++)); do
        local frame_address=$(printf "0x%016x" $((0x7fff00000000 + (RANDOM % 1000) * 4096)))
        local symbol_offset=$((RANDOM % 1000))
        local symbol_name=""
        
        case $((i % 4)) in
            0) symbol_name="CFRunLoopRun" ;;
            1) symbol_name="NSApplicationMain" ;;
            2) symbol_name="main" ;;
            3) symbol_name="start" ;;
        esac
        
        echo "   $i   $framework                          0x00007fff$frame_address $symbol_name + $symbol_offset"
    done
    
    echo ""
    echo "Thread $(($(date +%s) % 16)):: Dispatch queue: com.apple.libdispatch-manager"
    echo "  0   libdispatch.dylib                      0x00007fff$(printf "%012x" $((0x7fff00000000 + RANDOM * 4096))) _dispatch_mgr_invoke + 0"
    echo "  1   libdispatch.dylib                      0x00007fff$(printf "%012x" $((0x7fff00000000 + RANDOM * 4096))) _dispatch_mgr_wq_invoke + 0"
    echo "  2   libdispatch.dylib                      0x00007fff$(printf "%012x" $((0x7fff00000000 + RANDOM * 4096))) _dispatch_mgr_run + 0"
}

# Generate realistic binary images section
generate_binary_images() {
    cat << EOF

Binary Images:
       0x10$(printf "%012x" $((RANDOM * 4096))) -        0x10$(printf "%012x" $((RANDOM * 4096 + 0x1000))) +$process (0) <$(uuidgen | tr '[:lower:]' '[:upper:]')> /System/Library/CoreServices/$process
       0x7fff$(printf "%012x" $((0x7fff00000000 + RANDOM * 4096))) - 0x7fff$(printf "%012x" $((0x7fff00000000 + RANDOM * 4096 + 0x1000000))) +$framework (0) <$(uuidgen | tr '[:lower:]' '[:upper:]')> /System/Library/Frameworks/$framework.framework/Versions/A/$framework
       0x7fff$(printf "%012x" $((0x7fff00000000 + RANDOM * 4096))) - 0x7fff$(printf "%012x" $((0x7fff00000000 + RANDOM * 4096 + 0x1000000))) +libsystem_kernel.dylib (0) <$(uuidgen | tr '[:lower:]' '[:upper:]')> /usr/lib/system/libsystem_kernel.dylib
       0x7fff$(printf "%012x" $((0x7fff00000000 + RANDOM * 4096))) - 0x7fff$(printf "%012x" $((0x7fff00000000 + RANDOM * 4096 + 0x1000000))) +libsystem_c.dylib (0) <$(uuidgen | tr '[:lower:]' '[:upper:]')> /usr/lib/system/libsystem_c.dylib
EOF
}

# Create a forged diagnostic panic report
create_diagnostic_crumb() {
    local process="${PROCESSES[$((RANDOM % ${#PROCESSES[@]}))]}"
    local timestamp=$(date '+%Y-%m-%d-%H-%M-%S')
    local diag_file="$DIAGNOSTIC_DIR/${process}_${timestamp}.diagpanic"
    
    log "INFO" "Creating diagnostic breadcrumb: $diag_file"
    
    # Generate the diagnostic report
    {
        generate_stack_trace
        generate_binary_images
        
        cat << EOF

System Information:
    macOS Version: $(sw_vers -productVersion) ($(sw_vers -buildVersion))
    Kernel Version: Darwin $(uname -r)
    Boot Volume: $(df / | tail -1 | awk '{print $1}')
    Boot Mode: Normal
    Secure Virtual Memory: Enabled
    System Integrity Protection: Enabled
    Time since boot: $(($(date +%s) - $(sysctl -n kern.boottime | cut -d' ' -f4 | cut -d',' -f1))) seconds

EOF
    } > "$diag_file"
    
    # Set proper permissions
    chmod 644 "$diag_file"
    chown root:wheel "$diag_file"
    
    log "DEBUG" "Diagnostic breadcrumb created: $diag_file"
}

# Create diagnostic breadcrumbs
create_breadcrumbs() {
    log "RITUAL" "Beginning diagnostic breadcrumb ritual..."
    
    # Ensure diagnostic directory exists
    if [[ ! -d "$DIAGNOSTIC_DIR" ]]; then
        log "INFO" "Creating diagnostic directory: $DIAGNOSTIC_DIR"
        mkdir -p "$DIAGNOSTIC_DIR"
        chmod 755 "$DIAGNOSTIC_DIR"
        chown root:wheel "$DIAGNOSTIC_DIR"
    fi
    
    # Create multiple breadcrumbs with realistic timing
    local crumb_count=$((1 + RANDOM % 3))
    
    for ((i=0; i<crumb_count; i++)); do
        create_diagnostic_crumb
        
        # Add realistic delay between breadcrumbs
        if [[ $i -lt $((crumb_count - 1)) ]]; then
            sleep $((5 + RANDOM % 15))
        fi
    done
    
    log "INFO" "Created $crumb_count diagnostic breadcrumbs"
}

# Create persistent breadcrumb marker
create_breadcrumb_marker() {
    log "INFO" "Creating breadcrumb marker"
    
    local marker_file="$DIAGNOSTIC_DIR/.lilithos_breadcrumbs"
    cat > "$marker_file" << EOF
# LilithOS Diagnostic Breadcrumbs Marker
# This file marks the presence of LilithOS diagnostic breadcrumbs
# Generated: $(date)
# UUID: $LILITH_UUID
# Status: ACTIVE
# Integration: PERMANENT

LILITHOS_UUID="$LILITH_UUID"
BREADCRUMB_DATE="$(date +%Y-%m-%d)"
LAST_CRUMB="$(date +%Y-%m-%d %H:%M:%S)"
CRUMB_COUNT="$(find "$DIAGNOSTIC_DIR" -name "*.diagpanic" -newer "$marker_file" 2>/dev/null | wc -l)"
INTEGRATION_LEVEL="DIAGNOSTIC_DEEP"
EOF
    
    chmod 644 "$marker_file"
    chown root:wheel "$marker_file"
}

# Start continuous breadcrumb creation
start_breadcrumb_daemon() {
    log "INFO" "Starting diagnostic breadcrumb daemon"
    
    # Create initial breadcrumbs
    create_breadcrumbs
    create_breadcrumb_marker
    
    log "INFO" "Diagnostic breadcrumb daemon started"
    log "INFO" "Breadcrumbs will be created every $CRUMB_INTERVAL seconds"
    
    # Main daemon loop
    while true; do
        sleep "$CRUMB_INTERVAL"
        
        # Create new breadcrumbs
        create_diagnostic_crumb
        
        # Update marker
        sed -i '' "s/LAST_CRUMB=.*/LAST_CRUMB=\"$(date +%Y-%m-%d %H:%M:%S)\"/" "$DIAGNOSTIC_DIR/.lilithos_breadcrumbs" 2>/dev/null || true
        sed -i '' "s/CRUMB_COUNT=.*/CRUMB_COUNT=\"$(find "$DIAGNOSTIC_DIR" -name "*.diagpanic" -newer "$DIAGNOSTIC_DIR/.lilithos_breadcrumbs" 2>/dev/null | wc -l)\"/" "$DIAGNOSTIC_DIR/.lilithos_breadcrumbs" 2>/dev/null || true
        
        log "DEBUG" "Created new diagnostic breadcrumb"
    done
}

# Check breadcrumb status
check_status() {
    log "INFO" "Checking diagnostic breadcrumb status"
    
    if [[ -d "$DIAGNOSTIC_DIR" ]]; then
        log "INFO" "Diagnostic directory exists: $DIAGNOSTIC_DIR"
        
        # Count LilithOS breadcrumbs
        local breadcrumb_count=$(find "$DIAGNOSTIC_DIR" -name "*.diagpanic" 2>/dev/null | wc -l)
        log "INFO" "Total diagnostic reports: $breadcrumb_count"
        
        # Check for recent breadcrumbs
        local recent_breadcrumbs=$(find "$DIAGNOSTIC_DIR" -name "*.diagpanic" -mtime -1 2>/dev/null | wc -l)
        log "INFO" "Recent diagnostic reports (last 24h): $recent_breadcrumbs"
    else
        log "WARN" "Diagnostic directory not found"
    fi
    
    if [[ -f "$DIAGNOSTIC_DIR/.lilithos_breadcrumbs" ]]; then
        log "INFO" "Breadcrumb marker exists"
        local uuid=$(grep "LILITHOS_UUID=" "$DIAGNOSTIC_DIR/.lilithos_breadcrumbs" | cut -d'"' -f2)
        log "INFO" "LilithOS UUID: $uuid"
    else
        log "WARN" "Breadcrumb marker not found"
    fi
}

# Clean up diagnostic breadcrumbs
cleanup_breadcrumbs() {
    log "WARN" "Cleaning up diagnostic breadcrumbs..."
    
    # Remove LilithOS breadcrumbs
    find "$DIAGNOSTIC_DIR" -name "*.diagpanic" -exec grep -l "LilithOS\|$LILITH_UUID" {} \; 2>/dev/null | xargs rm -f 2>/dev/null || true
    
    # Remove breadcrumb marker
    rm -f "$DIAGNOSTIC_DIR/.lilithos_breadcrumbs"
    
    log "INFO" "Diagnostic breadcrumbs cleanup completed"
}

# Rollback function
rollback() {
    log "WARN" "Rolling back diagnostic breadcrumbs..."
    
    # Clean up current breadcrumbs
    cleanup_breadcrumbs
    
    # Restore from backup if available
    if [[ -d "$BACKUP_DIR" ]]; then
        if [[ -d "$BACKUP_DIR/DiagnosticReports" ]]; then
            cp -r "$BACKUP_DIR/DiagnosticReports" "/Library/Logs/" 2>/dev/null || log "WARN" "Could not restore diagnostic directory"
        fi
    fi
    
    log "INFO" "Rollback completed"
}

# Main execution function
main() {
    log "RITUAL" "🩸 LilithOS Diagnostic Breadcrumb Ritual Initiated 🩸"
    log "INFO" "Script: $SCRIPT_NAME"
    log "INFO" "LilithOS UUID: $LILITH_UUID"
    log "INFO" "Target System: $(uname -s) $(uname -r)"
    
    # Check for status flag
    if [[ "${1:-}" == "--status" ]]; then
        check_status
        exit 0
    fi
    
    # Check for cleanup flag
    if [[ "${1:-}" == "--cleanup" ]]; then
        check_privileges
        cleanup_breadcrumbs
        exit 0
    fi
    
    # Check for rollback flag
    if [[ "${1:-}" == "--rollback" ]]; then
        check_privileges
        rollback
        exit 0
    fi
    
    # Check for dry-run flag
    if [[ "${1:-}" == "--dry-run" ]]; then
        log "INFO" "DRY RUN MODE - No changes will be made"
        log "INFO" "Would create: diagnostic breadcrumbs, breadcrumb marker"
        exit 0
    fi
    
    # Perform diagnostic breadcrumb ritual
    check_privileges
    create_backup
    start_breadcrumb_daemon
    
    log "RITUAL" "🩸 LilithOS Diagnostic Breadcrumb Ritual Completed 🩸"
    log "INFO" "Diagnostic breadcrumbs are now being created in the system."
    log "INFO" "Diagnostic directory: $DIAGNOSTIC_DIR"
    log "INFO" "Use --status to check breadcrumb status"
    log "INFO" "Use --cleanup to remove breadcrumbs"
}

# Execute main function with all arguments
main "$@" 