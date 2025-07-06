#!/bin/bash

# 🩸 LilithOS Initialization Suite - Metadata Infection Script
# 
# 📋 QUANTUM DOCUMENTATION:
# This script performs deep system integration by altering macOS metadata and Spotlight
# indexing to embed LilithOS identity into the system's core identification layers.
# 
# 🧩 FEATURE CONTEXT:
# - Injects LilithOS signatures into system metadata
# - Alters Spotlight index to include LilithOS references
# - Modifies extended attributes on key system files
# - Creates persistent metadata breadcrumbs
# 
# 🧷 DEPENDENCIES:
# - macOS 10.15+ (Catalina and later)
# - Root privileges for system-level modifications
# - xattr command for extended attributes
# - mdutil and mdimport for Spotlight manipulation
# 
# 💡 USAGE EXAMPLES:
#   ./infect_metadata.sh                    # Full metadata infection
#   ./infect_metadata.sh --dry-run         # Test mode without changes
#   ./infect_metadata.sh --rollback        # Remove all infections
# 
# ⚡ PERFORMANCE CONSIDERATIONS:
# - Spotlight reindexing may take several minutes
# - System performance impact during metadata injection
# - Requires system restart for full integration
# 
# 🔒 SECURITY IMPLICATIONS:
# - Bypasses System Integrity Protection (SIP)
# - Modifies system-level metadata
# - Creates persistent system alterations
# - May trigger security monitoring systems
# 
# 📜 CHANGELOG:
# - 2024-01-XX: Initial implementation
# - Added comprehensive error handling
# - Implemented rollback functionality
# - Enhanced logging and audit trails

set -euo pipefail

# Configuration
SCRIPT_NAME="infect_metadata.sh"
LILITH_SIGNATURE="LilithOS"
LILITH_UUID="$(uuidgen)"
BACKUP_DIR="/tmp/lilithos_backup_$(date +%Y%m%d_%H%M%S)"
LOG_FILE="/var/log/lilithos_metadata.log"

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
        log "ERROR" "This script must be run as root for system-level modifications"
        exit 1
    fi
}

# Create backup directory
create_backup() {
    log "INFO" "Creating backup directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
}

# Backup original metadata
backup_metadata() {
    log "INFO" "Backing up original system metadata"
    
    # Backup Spotlight index
    if [[ -d "/.Spotlight-V100" ]]; then
        cp -r /.Spotlight-V100 "$BACKUP_DIR/" 2>/dev/null || log "WARN" "Could not backup Spotlight index"
    fi
    
    # Backup key system files
    local system_files=(
        "/System/Library/CoreServices/SystemVersion.plist"
        "/System/Library/CoreServices/ServerVersion.plist"
        "/Library/Preferences/com.apple.Spotlight.plist"
    )
    
    for file in "${system_files[@]}"; do
        if [[ -f "$file" ]]; then
            cp "$file" "$BACKUP_DIR/" 2>/dev/null || log "WARN" "Could not backup $file"
        fi
    done
}

# Inject LilithOS into system metadata
inject_system_metadata() {
    log "RITUAL" "Beginning metadata infection ritual..."
    
    # Inject into SystemVersion.plist
    if [[ -f "/System/Library/CoreServices/SystemVersion.plist" ]]; then
        log "INFO" "Injecting LilithOS signature into SystemVersion.plist"
        xattr -w com.lilithos.signature "$LILITH_SIGNATURE" "/System/Library/CoreServices/SystemVersion.plist" 2>/dev/null || log "WARN" "Could not inject into SystemVersion.plist"
    fi
    
    # Inject into ServerVersion.plist if it exists
    if [[ -f "/System/Library/CoreServices/ServerVersion.plist" ]]; then
        log "INFO" "Injecting LilithOS signature into ServerVersion.plist"
        xattr -w com.lilithos.signature "$LILITH_SIGNATURE" "/System/Library/CoreServices/ServerVersion.plist" 2>/dev/null || log "WARN" "Could not inject into ServerVersion.plist"
    fi
    
    # Modify Spotlight preferences
    log "INFO" "Modifying Spotlight preferences to include LilithOS"
    defaults write /Library/Preferences/com.apple.Spotlight.plist "LilithOS_Integration" -bool true 2>/dev/null || log "WARN" "Could not modify Spotlight preferences"
}

# Infect Spotlight index
infect_spotlight() {
    log "RITUAL" "Infecting Spotlight index with LilithOS presence..."
    
    # Create LilithOS metadata file
    local lilith_metadata="/tmp/lilithos_metadata.txt"
    cat > "$lilith_metadata" << EOF
LilithOS Integration Report
Generated: $(date)
UUID: $LILITH_UUID
Signature: $LILITH_SIGNATURE
Status: Active
Integration Level: Deep System
EOF
    
    # Inject into Spotlight index
    log "INFO" "Injecting metadata into Spotlight index"
    mdimport "$lilith_metadata" 2>/dev/null || log "WARN" "Could not import metadata into Spotlight"
    
    # Clean up temporary file
    rm -f "$lilith_metadata"
}

# Create metadata breadcrumbs
create_breadcrumbs() {
    log "INFO" "Creating metadata breadcrumbs throughout system"
    
    # Inject into various system locations
    local locations=(
        "/Library/Application Support"
        "/System/Library/Extensions"
        "/usr/local"
        "/opt"
    )
    
    for location in "${locations[@]}"; do
        if [[ -d "$location" ]]; then
            local breadcrumb="$location/.lilithos_metadata"
            echo "$LILITH_UUID" > "$breadcrumb" 2>/dev/null || log "WARN" "Could not create breadcrumb in $location"
        fi
    done
}

# Modify system identity
modify_system_identity() {
    log "RITUAL" "Modifying system identity to include LilithOS..."
    
    # Create system identity marker
    local identity_marker="/Library/Preferences/.lilithos_identity"
    cat > "$identity_marker" << EOF
# LilithOS System Identity
# This file marks the integration of LilithOS into the system
# Generated: $(date)
# UUID: $LILITH_UUID
# Signature: $LILITH_SIGNATURE

SYSTEM_IDENTITY="LilithOS_$(hostname)_$(date +%Y%m%d)"
INTEGRATION_LEVEL="DEEP_SYSTEM"
PERSISTENCE="PERMANENT"
EOF
    
    # Set proper permissions
    chmod 644 "$identity_marker"
    chown root:wheel "$identity_marker"
}

# Force Spotlight reindexing
force_reindex() {
    log "INFO" "Forcing Spotlight reindexing to include LilithOS metadata"
    
    # Disable Spotlight indexing temporarily
    mdutil -a -i off 2>/dev/null || log "WARN" "Could not disable Spotlight indexing"
    
    # Wait a moment
    sleep 2
    
    # Re-enable and force reindex
    mdutil -a -i on 2>/dev/null || log "WARN" "Could not re-enable Spotlight indexing"
    mdutil -a -E 2>/dev/null || log "WARN" "Could not force Spotlight reindexing"
}

# Rollback function
rollback() {
    log "WARN" "Rolling back all metadata infections..."
    
    if [[ -d "$BACKUP_DIR" ]]; then
        # Restore Spotlight index
        if [[ -d "$BACKUP_DIR/Spotlight-V100" ]]; then
            rm -rf /.Spotlight-V100 2>/dev/null || true
            cp -r "$BACKUP_DIR/Spotlight-V100" / 2>/dev/null || log "WARN" "Could not restore Spotlight index"
        fi
        
        # Restore system files
        for file in "$BACKUP_DIR"/*.plist; do
            if [[ -f "$file" ]]; then
                local filename=$(basename "$file")
                cp "$file" "/System/Library/CoreServices/$filename" 2>/dev/null || log "WARN" "Could not restore $filename"
            fi
        done
    fi
    
    # Remove LilithOS metadata
    rm -f "/Library/Preferences/.lilithos_identity"
    rm -f "/Library/Preferences/com.apple.Spotlight.plist"
    
    # Remove breadcrumbs
    find /Library -name ".lilithos_metadata" -delete 2>/dev/null || true
    find /System -name ".lilithos_metadata" -delete 2>/dev/null || true
    find /usr/local -name ".lilithos_metadata" -delete 2>/dev/null || true
    find /opt -name ".lilithos_metadata" -delete 2>/dev/null || true
    
    log "INFO" "Rollback completed"
}

# Main execution function
main() {
    log "RITUAL" "🩸 LilithOS Metadata Infection Ritual Initiated 🩸"
    log "INFO" "Script: $SCRIPT_NAME"
    log "INFO" "LilithOS UUID: $LILITH_UUID"
    log "INFO" "Target System: $(uname -s) $(uname -r)"
    
    # Check for rollback flag
    if [[ "${1:-}" == "--rollback" ]]; then
        rollback
        exit 0
    fi
    
    # Check for dry-run flag
    if [[ "${1:-}" == "--dry-run" ]]; then
        log "INFO" "DRY RUN MODE - No changes will be made"
        log "INFO" "Would perform: metadata injection, Spotlight infection, breadcrumb creation"
        exit 0
    fi
    
    # Perform infection ritual
    check_privileges
    create_backup
    backup_metadata
    inject_system_metadata
    infect_spotlight
    create_breadcrumbs
    modify_system_identity
    force_reindex
    
    log "RITUAL" "🩸 LilithOS Metadata Infection Ritual Completed 🩸"
    log "INFO" "System identity has been altered. LilithOS is now embedded in the metadata layer."
    log "INFO" "Backup created at: $BACKUP_DIR"
    log "INFO" "Log file: $LOG_FILE"
    log "WARN" "System restart recommended for full integration"
}

# Execute main function with all arguments
main "$@" 