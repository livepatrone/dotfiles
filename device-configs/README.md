# Device-Specific Configurations

This directory contains device-specific configuration overrides that won't be synced across all devices.

## Usage

Create a subdirectory named after your device hostname, e.g.:
```
device-configs/
├── my-laptop/
├── my-desktop/
└── work-machine/
```

Each device directory can contain:
- `local.env` - Environment variables specific to this device
- `local.bashrc` - Device-specific bash configuration
- Any config file that needs device-specific values

## Example Structure

```
device-configs/my-laptop/
├── local.env              # Device-specific environment vars
├── local.bashrc           # Device-specific bash config
└── gtk-3.0/
    └── settings.ini       # Display scaling for laptop
```

The bootstrap script will automatically source these files if they exist for the current hostname.