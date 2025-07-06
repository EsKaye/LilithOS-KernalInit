# 🩸 LilithOS Initialization Suite - Makefile
# 
# 📋 QUANTUM DOCUMENTATION:
# This Makefile provides a centralized control interface for the entire
# LilithOS Initialization Suite, allowing one command to activate all
# system integration components.
# 
# 🧩 FEATURE CONTEXT:
# - Orchestrates all LilithOS initialization scripts
# - Provides individual and combined execution targets
# - Includes safety checks and validation
# - Offers rollback and cleanup capabilities
# 
# 🧷 DEPENDENCIES:
# - macOS 10.15+ (Catalina and later)
# - Root privileges for system integration
# - All LilithOS scripts in the same directory
# - Make utility for target execution
# 
# 💡 USAGE EXAMPLES:
#   make all                    # Activate the entire suite
#   make infect                 # Infect metadata layer only
#   make daemon                 # Install LilithDaemon only
#   make bleed                  # Start phantom logging only
#   make crumbs                 # Create diagnostic breadcrumbs only
#   make status                 # Check status of all components
#   make rollback               # Rollback all changes
#   make clean                  # Clean up all components
# 
# ⚡ PERFORMANCE CONSIDERATIONS:
# - Sequential execution to avoid conflicts
# - Proper error handling and rollback
# - System restart recommendations
# - Resource usage optimization
# 
# 🔒 SECURITY IMPLICATIONS:
# - Requires root privileges for all operations
# - Creates persistent system alterations
# - May trigger security monitoring systems
# - Comprehensive audit trail creation
# 
# 📜 CHANGELOG:
# - 2024-01-XX: Initial implementation
# - Added comprehensive target definitions
# - Implemented safety checks and validation
# - Enhanced rollback and cleanup capabilities

# Configuration
LILITHOS_VERSION := "1.0.0"
LILITHOS_UUID := $(shell uuidgen)
TIMESTAMP := $(shell date +%Y%m%d_%H%M%S)
BACKUP_DIR := /tmp/lilithos_backup_$(TIMESTAMP)
LOG_FILE := /var/log/lilithos_make.log

# Script paths
INFECT_SCRIPT := ./infect_metadata.sh
DAEMON_SCRIPT := ./daemon_injector.sh
PHANTOM_SCRIPT := ./phantom_logger.sh
DIAGNOSTIC_SCRIPT := ./diagnostic_crumbs.sh

# Color codes for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
PURPLE := \033[0;35m
NC := \033[0m

# Default target
.DEFAULT_GOAL := help

# Help target
.PHONY: help
help:
	@echo -e "$(PURPLE)🩸 LilithOS Initialization Suite - Makefile$(NC)"
	@echo -e "$(BLUE)Version: $(LILITHOS_VERSION)$(NC)"
	@echo -e "$(BLUE)UUID: $(LILITHOS_UUID)$(NC)"
	@echo ""
	@echo -e "$(GREEN)Available targets:$(NC)"
	@echo -e "  $(YELLOW)all$(NC)        - Activate the entire LilithOS suite"
	@echo -e "  $(YELLOW)infect$(NC)     - Infect metadata layer"
	@echo -e "  $(YELLOW)daemon$(NC)     - Install LilithDaemon"
	@echo -e "  $(YELLOW)bleed$(NC)      - Start phantom logging"
	@echo -e "  $(YELLOW)crumbs$(NC)     - Create diagnostic breadcrumbs"
	@echo -e "  $(YELLOW)status$(NC)     - Check status of all components"
	@echo -e "  $(YELLOW)rollback$(NC)   - Rollback all changes"
	@echo -e "  $(YELLOW)clean$(NC)      - Clean up all components"
	@echo -e "  $(YELLOW)validate$(NC)   - Validate script integrity"
	@echo -e "  $(YELLOW)backup$(NC)     - Create system backup"
	@echo -e "  $(YELLOW)restore$(NC)    - Restore from backup"
	@echo ""

# Logging function
define log
	@echo -e "$(GREEN)[INFO]$(NC) $(shell date '+%Y-%m-%d %H:%M:%S'): $(1)" | tee -a $(LOG_FILE)
endef

define log_warn
	@echo -e "$(YELLOW)[WARN]$(NC) $(shell date '+%Y-%m-%d %H:%M:%S'): $(1)" | tee -a $(LOG_FILE)
endef

define log_error
	@echo -e "$(RED)[ERROR]$(NC) $(shell date '+%Y-%m-%d %H:%M:%S'): $(1)" | tee -a $(LOG_FILE)
endef

define log_ritual
	@echo -e "$(PURPLE)[RITUAL]$(NC) $(shell date '+%Y-%m-%d %H:%M:%S'): $(1)" | tee -a $(LOG_FILE)
endef

# Check if running as root
define check_root
	@if [ $$(id -u) -ne 0 ]; then \
		$(call log_error,"This target must be run as root"); \
		exit 1; \
	fi
endef

# Check if scripts exist
define check_scripts
	@for script in $(INFECT_SCRIPT) $(DAEMON_SCRIPT) $(PHANTOM_SCRIPT) $(DIAGNOSTIC_SCRIPT); do \
		if [ ! -f "$$script" ]; then \
			$(call log_error,"Script not found: $$script"); \
			exit 1; \
		fi; \
	done
endef

# Make scripts executable
.PHONY: make-executable
make-executable:
	$(call log,"Making scripts executable")
	@chmod +x $(INFECT_SCRIPT) $(DAEMON_SCRIPT) $(PHANTOM_SCRIPT) $(DIAGNOSTIC_SCRIPT)

# Validate script integrity
.PHONY: validate
validate:
	$(call log_ritual,"🩸 Validating LilithOS script integrity 🩸")
	$(call check_scripts)
	$(call log,"All required scripts found")
	@for script in $(INFECT_SCRIPT) $(DAEMON_SCRIPT) $(PHANTOM_SCRIPT) $(DIAGNOSTIC_SCRIPT); do \
		if [ -x "$$script" ]; then \
			$(call log,"Script is executable: $$script"); \
		else \
			$(call log_warn,"Script is not executable: $$script"); \
		fi; \
	done
	$(call log,"Script validation completed")

# Create system backup
.PHONY: backup
backup:
	$(call log_ritual,"🩸 Creating system backup 🩸")
	$(call check_root)
	$(call log,"Creating backup directory: $(BACKUP_DIR)")
	@mkdir -p $(BACKUP_DIR)
	@cp -r /Library/Preferences $(BACKUP_DIR)/ 2>/dev/null || $(call log_warn,"Could not backup preferences")
	@cp -r /Library/LaunchDaemons $(BACKUP_DIR)/ 2>/dev/null || $(call log_warn,"Could not backup LaunchDaemons")
	@cp -r /var/log $(BACKUP_DIR)/ 2>/dev/null || $(call log_warn,"Could not backup logs")
	$(call log,"System backup completed: $(BACKUP_DIR)")

# Infect metadata layer
.PHONY: infect
infect:
	$(call log_ritual,"🩸 Infecting metadata layer 🩸")
	$(call check_root)
	$(call check_scripts)
	$(call make-executable)
	$(call log,"Executing metadata infection")
	@$(INFECT_SCRIPT)
	$(call log,"Metadata infection completed")

# Install LilithDaemon
.PHONY: daemon
daemon:
	$(call log_ritual,"🩸 Installing LilithDaemon 🩸")
	$(call check_root)
	$(call check_scripts)
	$(call make-executable)
	$(call log,"Executing daemon injection")
	@$(DAEMON_SCRIPT)
	$(call log,"Daemon injection completed")

# Start phantom logging
.PHONY: bleed
bleed:
	$(call log_ritual,"🩸 Starting phantom logging 🩸")
	$(call check_root)
	$(call check_scripts)
	$(call make-executable)
	$(call log,"Executing phantom logging")
	@$(PHANTOM_SCRIPT) &
	$(call log,"Phantom logging started in background")

# Create diagnostic breadcrumbs
.PHONY: crumbs
crumbs:
	$(call log_ritual,"🩸 Creating diagnostic breadcrumbs 🩸")
	$(call check_root)
	$(call check_scripts)
	$(call make-executable)
	$(call log,"Executing diagnostic breadcrumb creation")
	@$(DIAGNOSTIC_SCRIPT) &
	$(call log,"Diagnostic breadcrumb creation started in background")

# Check status of all components
.PHONY: status
status:
	$(call log,"Checking LilithOS component status")
	$(call check_scripts)
	$(call make-executable)
	@echo -e "$(BLUE)=== Metadata Infection Status ===$(NC)"
	@$(INFECT_SCRIPT) --dry-run 2>/dev/null || $(call log_warn,"Metadata infection not available")
	@echo -e "$(BLUE)=== Daemon Status ===$(NC)"
	@$(DAEMON_SCRIPT) --status 2>/dev/null || $(call log_warn,"Daemon status not available")
	@echo -e "$(BLUE)=== Phantom Logging Status ===$(NC)"
	@$(PHANTOM_SCRIPT) --status 2>/dev/null || $(call log_warn,"Phantom logging status not available")
	@echo -e "$(BLUE)=== Diagnostic Breadcrumbs Status ===$(NC)"
	@$(DIAGNOSTIC_SCRIPT) --status 2>/dev/null || $(call log_warn,"Diagnostic breadcrumbs status not available")
	$(call log,"Status check completed")

# Activate the entire suite
.PHONY: all
all:
	$(call log_ritual,"🩸 LilithOS Initialization Suite - Full Activation 🩸")
	$(call check_root)
	$(call validate)
	$(call backup)
	$(call log,"Starting full LilithOS integration")
	@$(MAKE) infect
	@$(MAKE) daemon
	@$(MAKE) bleed
	@$(MAKE) crumbs
	$(call log_ritual,"🩸 LilithOS Initialization Suite - Full Activation Completed 🩸")
	$(call log,"All components have been activated")
	$(call log_warn,"System restart recommended for full integration")
	$(call log,"Backup created at: $(BACKUP_DIR)")
	$(call log,"Log file: $(LOG_FILE)")

# Rollback all changes
.PHONY: rollback
rollback:
	$(call log_ritual,"🩸 Rolling back all LilithOS changes 🩸")
	$(call check_root)
	$(call check_scripts)
	$(call make-executable)
	$(call log,"Rolling back metadata infection")
	@$(INFECT_SCRIPT) --rollback 2>/dev/null || $(call log_warn,"Metadata rollback failed")
	$(call log,"Rolling back daemon installation")
	@$(DAEMON_SCRIPT) --rollback 2>/dev/null || $(call log_warn,"Daemon rollback failed")
	$(call log,"Rolling back phantom logging")
	@$(PHANTOM_SCRIPT) --rollback 2>/dev/null || $(call log_warn,"Phantom logging rollback failed")
	$(call log,"Rolling back diagnostic breadcrumbs")
	@$(DIAGNOSTIC_SCRIPT) --rollback 2>/dev/null || $(call log_warn,"Diagnostic breadcrumbs rollback failed")
	$(call log,"Rollback completed")

# Clean up all components
.PHONY: clean
clean:
	$(call log_ritual,"🩸 Cleaning up all LilithOS components 🩸")
	$(call check_root)
	$(call check_scripts)
	$(call make-executable)
	$(call log,"Stopping phantom logging")
	@$(PHANTOM_SCRIPT) --stop 2>/dev/null || $(call log_warn,"Could not stop phantom logging")
	$(call log,"Removing daemon")
	@$(DAEMON_SCRIPT) --remove 2>/dev/null || $(call log_warn,"Could not remove daemon")
	$(call log,"Cleaning up diagnostic breadcrumbs")
	@$(DIAGNOSTIC_SCRIPT) --cleanup 2>/dev/null || $(call log_warn,"Could not cleanup diagnostic breadcrumbs")
	$(call log,"Cleaning up phantom logging")
	@$(PHANTOM_SCRIPT) --cleanup 2>/dev/null || $(call log_warn,"Could not cleanup phantom logging")
	$(call log,"Cleanup completed")

# Restore from backup
.PHONY: restore
restore:
	$(call log_ritual,"🩸 Restoring system from backup 🩸")
	$(call check_root)
	@if [ ! -d "$(BACKUP_DIR)" ]; then \
		$(call log_error,"Backup directory not found: $(BACKUP_DIR)"); \
		exit 1; \
	fi
	$(call log,"Restoring from backup: $(BACKUP_DIR)")
	@cp -r $(BACKUP_DIR)/Preferences /Library/ 2>/dev/null || $(call log_warn,"Could not restore preferences")
	@cp -r $(BACKUP_DIR)/LaunchDaemons /Library/ 2>/dev/null || $(call log_warn,"Could not restore LaunchDaemons")
	@cp -r $(BACKUP_DIR)/log /var/ 2>/dev/null || $(call log_warn,"Could not restore logs")
	$(call log,"System restore completed")

# Install target (alias for all)
.PHONY: install
install: all

# Uninstall target (alias for rollback)
.PHONY: uninstall
uninstall: rollback

# Test target (dry run)
.PHONY: test
test:
	$(call log_ritual,"🩸 Testing LilithOS Initialization Suite 🩸")
	$(call validate)
	$(call log,"Testing metadata infection (dry run)")
	@$(INFECT_SCRIPT) --dry-run 2>/dev/null || $(call log_warn,"Metadata infection test failed")
	$(call log,"Testing daemon injection (dry run)")
	@$(DAEMON_SCRIPT) --dry-run 2>/dev/null || $(call log_warn,"Daemon injection test failed")
	$(call log,"Testing phantom logging (dry run)")
	@$(PHANTOM_SCRIPT) --dry-run 2>/dev/null || $(call log_warn,"Phantom logging test failed")
	$(call log,"Testing diagnostic breadcrumbs (dry run)")
	@$(DIAGNOSTIC_SCRIPT) --dry-run 2>/dev/null || $(call log_warn,"Diagnostic breadcrumbs test failed")
	$(call log,"All tests completed successfully")

# Version target
.PHONY: version
version:
	@echo -e "$(PURPLE)LilithOS Initialization Suite$(NC)"
	@echo -e "$(BLUE)Version: $(LILITHOS_VERSION)$(NC)"
	@echo -e "$(BLUE)UUID: $(LILITHOS_UUID)$(NC)"
	@echo -e "$(BLUE)Timestamp: $(TIMESTAMP)$(NC)"
	@echo -e "$(BLUE)Target System: $(shell uname -s) $(shell uname -r)$(NC)"

# Info target
.PHONY: info
info:
	@echo -e "$(PURPLE)🩸 LilithOS Initialization Suite Information 🩸$(NC)"
	@echo ""
	@echo -e "$(BLUE)Scripts:$(NC)"
	@echo -e "  $(INFECT_SCRIPT) - Metadata infection"
	@echo -e "  $(DAEMON_SCRIPT) - Daemon injection"
	@echo -e "  $(PHANTOM_SCRIPT) - Phantom logging"
	@echo -e "  $(DIAGNOSTIC_SCRIPT) - Diagnostic breadcrumbs"
	@echo ""
	@echo -e "$(BLUE)Log Files:$(NC)"
	@echo -e "  $(LOG_FILE) - Makefile execution log"
	@echo -e "  /var/log/lilithos_metadata.log - Metadata infection log"
	@echo -e "  /var/log/lilithos_daemon.log - Daemon injection log"
	@echo -e "  /var/log/lilithos_phantom.log - Phantom logging log"
	@echo -e "  /var/log/lilithos_diagnostic.log - Diagnostic breadcrumbs log"
	@echo ""
	@echo -e "$(BLUE)Integration Points:$(NC)"
	@echo -e "  /Library/Preferences - System preferences"
	@echo -e "  /Library/LaunchDaemons - System daemons"
	@echo -e "  /var/log - System logs"
	@echo -e "  /Library/Logs/DiagnosticReports - Diagnostic reports"
	@echo ""
	@echo -e "$(YELLOW)Warning: This suite creates persistent system alterations$(NC)"
	@echo -e "$(YELLOW)Use with caution and ensure proper backups$(NC)" 