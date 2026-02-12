# Jellyfin Module

Custom Jellyfin media server module with hardware acceleration support.

## Usage

### Enable in host configuration:

```nix
imports = [
  ../../modules/01-jellyfin
];

myServices.jellyfin = {
  enable = true;
  openFirewall = true;  # Default: true
  dataDir = "/var/lib/jellyfin";  # Default
};
```

### With hardware acceleration (Intel):

```nix
myServices.jellyfin = {
  enable = true;
  hardwareAcceleration = {
    enable = true;
    type = "vaapi";  # or "qsv" for Quick Sync
    device = "/dev/dri/renderD128";
  };
};
```

### With hardware acceleration (NVIDIA):

```nix
myServices.jellyfin = {
  enable = true;
  hardwareAcceleration = {
    enable = true;
    type = "nvenc";
    device = null;  # Not needed for NVIDIA
  };
};
```

## Options

- `myServices.jellyfin.enable` - Enable Jellyfin media server
- `myServices.jellyfin.openFirewall` - Open firewall ports (default: true)
- `myServices.jellyfin.dataDir` - Data directory (default: `/var/lib/jellyfin`)
- `myServices.jellyfin.hardwareAcceleration.enable` - Enable hardware transcoding
- `myServices.jellyfin.hardwareAcceleration.type` - Acceleration type: `vaapi`, `nvenc`, `qsv`, `amf`, `v4l2m2m`, `rkmpp`
- `myServices.jellyfin.hardwareAcceleration.device` - Device path (default: `/dev/dri/renderD128`)

## Access

After enabling, Jellyfin will be accessible at:
- **Web Interface:** http://localhost:8096

## Ports

- **TCP 8096** - HTTP web interface
- **TCP 8920** - HTTPS web interface
- **UDP 1900** - Service discovery
- **UDP 7359** - Client discovery

## Features

- ✅ Automatic firewall configuration
- ✅ Hardware acceleration support (VA-API, NVENC, QSV, AMF)
- ✅ Proper user permissions for GPU access
- ✅ Optimized FFmpeg for transcoding
- ✅ Configurable data directory
