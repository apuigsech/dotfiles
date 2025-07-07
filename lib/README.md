# Dotfiles Library Functions

This directory contains enhanced shell library functions that provide comprehensive functionality for the dotfiles system.

## Libraries

### `cache` - Performance Caching System

Provides intelligent caching for command results and system information to improve performance.

**Features:**
- Configurable TTL (Time To Live) for cache entries
- Automatic cache cleanup and expiration
- Command result caching with failure handling
- System information caching (OS, architecture, etc.)
- Cache statistics and management

**Functions:**
- `cache_get()` / `cache_set()` - Basic cache operations
- `cache_cmd()` - Cache command execution results
- `cache_has_cmd()` - Cached command existence checks
- `cache_is_macos()` / `cache_is_linux()` - Cached platform detection
- `cache_stats()` - Show cache statistics
- `cache_cleanup()` - Clean expired entries
- `cache_clear_all()` - Clear all cache

**Environment Variables:**
- `DOTFILES_CACHE_ENABLED` - Enable/disable caching
- `DOTFILES_CACHE_TTL` - Cache time-to-live in seconds

### `security` - Security and Input Validation

Provides comprehensive security features including input sanitization and secure file operations.

**Features:**
- Input sanitization for filenames, paths, commands, and URLs
- Secure file operations with validation
- File integrity checking with multiple hash algorithms
- Security auditing for permissions and file sizes
- Secure environment configuration

**Functions:**
- `sanitize_filename()` / `sanitize_path()` - Input sanitization
- `secure_download()` / `secure_copy()` - Secure file operations
- `validate_file_integrity()` - Hash-based integrity checking
- `audit_permissions()` / `audit_file_sizes()` - Security auditing
- `secure_environment()` - Environment hardening

**Environment Variables:**
- `DOTFILES_SECURITY_STRICT` - Enable strict security mode
- `DOTFILES_MAX_FILE_SIZE` - Maximum allowed file size

### `config` - Configuration Management

Centralized configuration system with file-based storage and environment variable overrides.

**Features:**
- Hierarchical configuration with defaults
- Environment variable overrides
- Configuration validation
- Automatic config file generation
- Helper functions for different data types

**Functions:**
- `config_get()` / `config_set()` - Basic configuration operations
- `config_get_bool()` / `config_get_int()` / `config_get_array()` - Typed getters
- `config_show()` - Display current configuration
- `config_validate()` - Validate configuration values
- `config_reset()` - Reset to defaults
- `config_export()` - Export as environment variables

### `test` - Testing Framework

Comprehensive testing framework with assertions, mocking, and benchmarking capabilities.

**Features:**
- Rich assertion functions for different test scenarios
- Test lifecycle management (setup, teardown, before/after each)
- Mocking capabilities for external commands
- Benchmarking and performance testing
- Colored output and detailed reporting

**Functions:**
- `assert_equals()` / `assert_true()` / `assert_false()` - Basic assertions
- `assert_file_exists()` / `assert_command_success()` - File and command assertions
- `run_test()` / `run_test_suite()` / `run_all_tests()` - Test runners
- `mock_command()` / `unmock_command()` - Command mocking
- `benchmark()` - Performance testing

### `platform` - Cross-Platform Compatibility

Comprehensive platform detection and compatibility layer for different operating systems and shells.

**Features:**
- Detailed platform detection (OS, architecture, shell, distribution)
- Cross-platform command wrappers
- Package manager detection and abstraction
- Platform-specific path helpers
- Feature detection (systemd, colors, unicode, etc.)

**Functions:**
- `detect_os()` / `detect_arch()` / `detect_shell()` - Platform detection
- `platform_stat()` / `platform_find()` / `platform_sed()` - Cross-platform commands
- `get_package_manager()` / `install_package()` - Package management
- `show_platform_info()` - Display platform information
- `get_config_dir()` / `get_cache_dir()` - Platform-specific paths

### `logger` - Comprehensive Logging System

Provides structured logging with multiple levels, colors, and file output.

**Features:**
- Multiple log levels (DEBUG, INFO, WARN, ERROR)
- Colored terminal output
- File logging with timestamps
- Log rotation (keeps last 10 log files)
- Configurable log levels

**Functions:**
- `log_debug()` - Debug messages
- `log_info()` - Informational messages
- `log_warn()` - Warning messages
- `log_error()` - Error messages
- `log_cmd()` - Log command execution
- `set_log_level()` - Set logging level
- `get_log_file()` - Get current log file path

**Environment Variables:**
- `DOTFILES_LOG_LEVEL` - Set log level (debug/info/warn/error)

### `progress` - Progress Tracking and Status Display

Provides visual progress indicators and status reporting.

**Features:**
- Spinner animations
- Progress bars
- Status reporting with checkmarks
- Success/failure tracking
- Terminal capability detection

**Functions:**
- `run_task()` - Run command with progress display
- `run_with_spinner()` - Run with spinner animation
- `run_with_status()` - Run with simple status display
- `init_progress()` - Initialize progress tracking
- `print_progress_summary()` - Show final summary

### `utils` - Enhanced Utility Functions

Core utility functions with improved error handling and validation.

**Features:**
- Command existence checking
- Directory sourcing with validation
- PATH management with duplicate detection
- Platform detection
- Retry mechanisms
- Safe file operations

**Functions:**
- `has_cmd()` - Check if command exists
- `source_dir()` - Source all files in directory
- `prepend_path()` / `append_path()` - Manage PATH
- `is_macos()` / `is_linux()` / `is_wsl()` - Platform detection
- `retry()` - Retry commands with exponential backoff
- `safe_backup()` - Backup files safely
- `safe_mkdir()` - Create directories safely
- `safe_download()` - Download files with retry
- `clean_path()` - Remove PATH duplicates

### `brew` - Enhanced Homebrew Management

Comprehensive Homebrew package management with error handling.

**Features:**
- Automatic Homebrew installation
- Package installation with validation
- Batch package installation from files
- Platform-specific path detection
- Prerequisites validation

**Functions:**
- `brew_install()` - Install Homebrew
- `brew_install_pkg()` - Install single package
- `brew_install_pkgs()` - Install from package file
- `brew_is_installed()` - Check if Homebrew is installed
- `brew_is_package_installed()` - Check if package is installed
- `brew_cleanup()` - Clean up Homebrew
- `brew_doctor()` - Run Homebrew doctor

### `dotbot` - Enhanced Dotbot Integration

Improved Dotbot wrapper with validation and error handling.

**Features:**
- Configuration validation
- Multiple config file support
- Dry-run support
- Verbose logging
- Help system

**Functions:**
- `dotbot()` - Run Dotbot with config
- `dotbot_run_config()` - Run specific config
- `dotbot_run_configs()` - Run multiple configs
- `dotbot_validate()` - Validate Dotbot installation
- `dotbot_test()` - Test Dotbot functionality
- `dotbot_help()` - Show help

### `errors` - Comprehensive Error Handling

Advanced error handling with trapping, context, and debugging.

**Features:**
- Error trapping and stack traces
- Context-aware error reporting
- Debug/strict/fail-fast modes
- Temporary file cleanup
- Signal handling

**Functions:**
- `set_error_context()` / `clear_error_context()` - Error context
- `run_with_context()` - Run with error context
- `enable_debug()` / `disable_debug()` - Debug mode
- `enable_strict()` / `disable_strict()` - Strict mode
- `assert()` - Assertion function
- `require()` - Dependency validation

**Environment Variables:**
- `DOTFILES_DEBUG` - Enable debug mode
- `DOTFILES_STRICT` - Enable strict mode
- `DOTFILES_FAIL_FAST` - Enable fail-fast mode

## Usage Examples

### Basic Logging
```bash
source lib/logger
log_info "Starting installation"
log_error "Something went wrong"
```

### Progress Tracking
```bash
source lib/progress
init_progress 5
run_task "Installing packages" brew install git
print_progress_summary
```

### Error Handling
```bash
source lib/errors
enable_strict
set_error_context "package installation"
run_with_context "Installing git" brew install git
```

### Homebrew Management
```bash
source lib/brew
brew_install
brew_install_pkg "git"
brew_install_pkgs "packages.lst"
```

### Dotbot Integration
```bash
source lib/dotbot
dotbot -c setup.dotbot
dotbot_run_configs *.dotbot
```

## Integration

The enhanced bootstrap script (`bootstap`) automatically sources all libraries and provides command-line options for configuration:

```bash
./bootstap --debug --verbose    # Debug mode with verbose logging
./bootstap --strict --fail-fast # Strict mode, exit on first error
./bootstap --help               # Show help
```

## Benefits

1. **Reliability**: Comprehensive error handling prevents partial installations
2. **Performance**: Intelligent caching reduces redundant operations
3. **Security**: Input validation and secure file operations protect against vulnerabilities
4. **Debugging**: Detailed logging and stack traces for troubleshooting
5. **User Experience**: Progress indicators and clear status messages
6. **Maintainability**: Modular design with clear separation of concerns
7. **Flexibility**: Configurable behavior through centralized configuration
8. **Cross-Platform**: Works consistently across different operating systems and shells
9. **Testability**: Built-in testing framework ensures code quality
10. **Configurability**: Centralized configuration management with validation