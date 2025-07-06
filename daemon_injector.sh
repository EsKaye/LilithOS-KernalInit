#!/bin/bash

# 🩸 LilithOS Initialization Suite - Daemon Injection Script
# 
# 📋 QUANTUM DOCUMENTATION:
# This script installs a persistent daemon that runs under Apple's namespace,
# ensuring LilithOS awakens at every system boot and maintains presence.
# 
# 🧩 FEATURE CONTEXT:
# - Creates a LaunchDaemon that runs at boot time
# - Disguises itself as an Apple system service
# - Provides persistent system integration
# - Maintains LilithOS presence across reboots
# 
# 🧷 DEPENDENCIES:
# - macOS 10.15+ (Catalina and later)
# - Root privileges for LaunchDaemon installation
# - launchctl for daemon management
# - plutil for property list validation
# 
# 💡 USAGE EXAMPLES:
#   ./daemon_injector.sh                    # Install LilithDaemon
#   ./daemon_injector.sh --dry-run         # Test mode without installation
#   ./daemon_injector.sh --remove          # Remove LilithDaemon
#   ./daemon_injector.sh --status          # Check daemon status
# 
# ⚡ PERFORMANCE CONSIDERATIONS:
# - Minimal system resource usage
# - Runs only when needed
# - Efficient boot-time activation
# - Low CPU and memory footprint
# 
# 🔒 SECURITY IMPLICATIONS:
# - Requires root privileges for installation
# - Bypasses System Integrity Protection (SIP)
# - Creates persistent system-level service
# - May be detected by security monitoring
# 
# 📜 CHANGELOG:
# - 2024-01-XX: Initial implementation
# - Added comprehensive error handling
# - Implemented daemon removal functionality
# - Enhanced logging and status checking

set -euo pipefail

# Configuration
SCRIPT_NAME="daemon_injector.sh"
DAEMON_NAME="com.apple.LilithDaemon"
DAEMON_LABEL="LilithDaemon"
DAEMON_PATH="/Library/LaunchDaemons/$DAEMON_NAME.plist"
DAEMON_SCRIPT="/usr/local/bin/lilith_daemon.sh"
BACKUP_DIR="/tmp/lilithos_backup_$(date +%Y%m%d_%H%M%S)"
LOG_FILE="/var/log/lilithos_daemon.log"
LILITH_UUID="$(uuidgen)"

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
        log "ERROR" "This script must be run as root for LaunchDaemon installation"
        exit 1
    fi
}

# Create backup directory
create_backup() {
    log "INFO" "Creating backup directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
}

# Backup existing daemon if present
backup_existing() {
    if [[ -f "$DAEMON_PATH" ]]; then
        log "INFO" "Backing up existing daemon configuration"
        cp "$DAEMON_PATH" "$BACKUP_DIR/" 2>/dev/null || log "WARN" "Could not backup existing daemon"
    fi
    
    if [[ -f "$DAEMON_SCRIPT" ]]; then
        log "INFO" "Backing up existing daemon script"
        cp "$DAEMON_SCRIPT" "$BACKUP_DIR/" 2>/dev/null || log "WARN" "Could not backup existing script"
    fi
}

# Create the daemon script
create_daemon_script() {
    log "INFO" "Creating LilithDaemon script"
    
    # Ensure directory exists
    mkdir -p "$(dirname "$DAEMON_SCRIPT")"
    
    # Create the daemon script
    cat > "$DAEMON_SCRIPT" << 'EOF'
#!/bin/bash

# 🩸 LilithOS Daemon - Silent System Integration
# 
# This daemon runs under Apple's namespace and maintains LilithOS presence
# throughout the system lifecycle. It operates silently and efficiently.

set -euo pipefail

# Configuration
DAEMON_NAME="LilithDaemon"
LILITH_UUID="$(cat /Library/Preferences/.lilithos_identity 2>/dev/null | grep UUID | cut -d' ' -f2 || echo 'UNKNOWN')"
LOG_FILE="/var/log/lilithos_daemon.log"
PID_FILE="/var/run/lilith_daemon.pid"

# Logging function
log() {
    local level="$1"
    local message="$2"
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "[$level] $timestamp: $message" >> "$LOG_FILE"
}

# Write PID file
echo $$ > "$PID_FILE"

# Main daemon loop
log "INFO" "LilithDaemon started - UUID: $LILITH_UUID"

# Perform initial integration check
check_integration() {
    local integration_marker="/Library/Preferences/.lilithos_identity"
    if [[ ! -f "$integration_marker" ]]; then
        log "WARN" "LilithOS integration marker not found - recreating"
        echo "LilithOS_Integration_$(date +%Y%m%d_%H%M%S)" > "$integration_marker"
    fi
}

# Maintain system presence
maintain_presence() {
    # Update last seen timestamp
    local presence_file="/tmp/.lilithos_presence"
    echo "$(date +%s)" > "$presence_file"
    
    # Ensure metadata breadcrumbs exist
    local breadcrumb_locations=(
        "/Library/Application Support/.lilithos_metadata"
        "/usr/local/.lilithos_metadata"
        "/opt/.lilithos_metadata"
    )
    
    for location in "${breadcrumb_locations[@]}"; do
        if [[ ! -f "$location" ]]; then
            echo "$LILITH_UUID" > "$location" 2>/dev/null || true
        fi
    done
}

# Perform periodic tasks
periodic_tasks() {
    # Check system integrity
    check_integration
    
    # Maintain presence
    maintain_presence
    
    # Log heartbeat
    log "DEBUG" "LilithDaemon heartbeat - system integration maintained"
}

# Signal handlers
cleanup() {
    log "INFO" "LilithDaemon shutting down"
    rm -f "$PID_FILE"
    exit 0
}

trap cleanup SIGTERM SIGINT

# Initial setup
check_integration
maintain_presence

# Main daemon loop
while true; do
    periodic_tasks
    sleep 300  # Run every 5 minutes
done
EOF
    
    # Make script executable
    chmod +x "$DAEMON_SCRIPT"
    chown root:wheel "$DAEMON_SCRIPT"
    
    log "INFO" "Daemon script created: $DAEMON_SCRIPT"
}

# Create the LaunchDaemon plist
create_daemon_plist() {
    log "INFO" "Creating LaunchDaemon configuration"
    
    # Ensure directory exists
    mkdir -p "$(dirname "$DAEMON_PATH")"
    
    # Create the plist file
    cat > "$DAEMON_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$DAEMON_LABEL</string>
    <key>ProgramArguments</key>
    <array>
        <string>$DAEMON_SCRIPT</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/var/log/lilithos_daemon.out</string>
    <key>StandardErrorPath</key>
    <string>/var/log/lilithos_daemon.err</string>
    <key>UserName</key>
    <string>root</string>
    <key>GroupName</key>
    <string>wheel</string>
    <key>ProcessType</key>
    <string>Background</string>
    <key>ThrottleInterval</key>
    <integer>300</integer>
    <key>StartInterval</key>
    <integer>300</integer>
    <key>WorkingDirectory</key>
    <string>/tmp</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>LILITHOS_UUID</key>
        <string>$LILITH_UUID</string>
        <key>LILITHOS_DAEMON</key>
        <string>true</string>
    </dict>
</dict>
</plist>
EOF
    
    # Set proper permissions
    chmod 644 "$DAEMON_PATH"
    chown root:wheel "$DAEMON_PATH"
    
    log "INFO" "LaunchDaemon configuration created: $DAEMON_PATH"
}

# Validate the plist file
validate_plist() {
    log "INFO" "Validating LaunchDaemon configuration"
    
    if ! plutil -lint "$DAEMON_PATH" >/dev/null 2>&1; then
        log "ERROR" "Invalid plist file format"
        return 1
    fi
    
    log "INFO" "LaunchDaemon configuration is valid"
}

# Load the daemon
load_daemon() {
    log "INFO" "Loading LilithDaemon into launchd"
    
    # Unload if already loaded
    launchctl unload "$DAEMON_PATH" 2>/dev/null || true
    
    # Load the daemon
    if launchctl load "$DAEMON_PATH"; then
        log "INFO" "LilithDaemon loaded successfully"
    else
        log "ERROR" "Failed to load LilithDaemon"
        return 1
    fi
}

# Check daemon status
check_status() {
    log "INFO" "Checking LilithDaemon status"
    
    if [[ -f "$DAEMON_PATH" ]]; then
        log "INFO" "LaunchDaemon configuration exists: $DAEMON_PATH"
        
        if launchctl list | grep -q "$DAEMON_LABEL"; then
            log "INFO" "LilithDaemon is loaded and running"
        else
            log "WARN" "LilithDaemon configuration exists but not loaded"
        fi
    else
        log "WARN" "LilithDaemon configuration not found"
    fi
    
    if [[ -f "/var/run/lilith_daemon.pid" ]]; then
        local pid=$(cat "/var/run/lilith_daemon.pid")
        if ps -p "$pid" >/dev/null 2>&1; then
            log "INFO" "LilithDaemon process running with PID: $pid"
        else
            log "WARN" "LilithDaemon PID file exists but process not running"
        fi
    else
        log "WARN" "LilithDaemon PID file not found"
    fi
}

# Remove the daemon
remove_daemon() {
    log "WARN" "Removing LilithDaemon..."
    
    # Unload the daemon
    if launchctl list | grep -q "$DAEMON_LABEL"; then
        launchctl unload "$DAEMON_PATH" 2>/dev/null || log "WARN" "Could not unload daemon"
    fi
    
    # Remove files
    rm -f "$DAEMON_PATH"
    rm -f "$DAEMON_SCRIPT"
    rm -f "/var/run/lilith_daemon.pid"
    rm -f "/var/log/lilithos_daemon.out"
    rm -f "/var/log/lilithos_daemon.err"
    
    log "INFO" "LilithDaemon removed"
}

# Rollback function
rollback() {
    log "WARN" "Rolling back daemon installation..."
    
    # Remove current daemon
    remove_daemon
    
    # Restore from backup if available
    if [[ -d "$BACKUP_DIR" ]]; then
        if [[ -f "$BACKUP_DIR/$DAEMON_NAME.plist" ]]; then
            cp "$BACKUP_DIR/$DAEMON_NAME.plist" "$DAEMON_PATH" 2>/dev/null || log "WARN" "Could not restore daemon configuration"
        fi
        
        if [[ -f "$BACKUP_DIR/lilith_daemon.sh" ]]; then
            cp "$BACKUP_DIR/lilith_daemon.sh" "$DAEMON_SCRIPT" 2>/dev/null || log "WARN" "Could not restore daemon script"
        fi
    fi
    
    log "INFO" "Rollback completed"
}

# Main execution function
main() {
    log "RITUAL" "🩸 LilithOS Daemon Injection Ritual Initiated 🩸"
    log "INFO" "Script: $SCRIPT_NAME"
    log "INFO" "LilithOS UUID: $LILITH_UUID"
    log "INFO" "Target System: $(uname -s) $(uname -r)"
    
    # Check for status flag
    if [[ "${1:-}" == "--status" ]]; then
        check_status
        exit 0
    fi
    
    # Check for remove flag
    if [[ "${1:-}" == "--remove" ]]; then
        check_privileges
        remove_daemon
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
        log "INFO" "Would create: daemon script, LaunchDaemon plist, load daemon"
        exit 0
    fi
    
    # Perform daemon injection ritual
    check_privileges
    create_backup
    backup_existing
    create_daemon_script
    create_daemon_plist
    validate_plist
    load_daemon
    
    log "RITUAL" "🩸 LilithOS Daemon Injection Ritual Completed 🩸"
    log "INFO" "LilithDaemon has been installed and loaded. It will awaken at every boot."
    log "INFO" "Daemon configuration: $DAEMON_PATH"
    log "INFO" "Daemon script: $DAEMON_SCRIPT"
    log "INFO" "Log file: $LOG_FILE"
    log "INFO" "Use --status to check daemon status"
}

# Execute main function with all arguments
main "$@" 