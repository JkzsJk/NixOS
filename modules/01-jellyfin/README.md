# Jellyfin Module

Custom Jellyfin media server module with hardware acceleration support.

## Structure

```
01-jellyfin/
  ├─ default.nix     - Entry point (imports all modules)
  ├─ 00-options.nix  - Module options definitions
  ├─ 01-service.nix  - Jellyfin service and packages
  ├─ 02-hardware.nix - Hardware acceleration configuration
  └─ 03-access.nix   - User permissions and media library access
```

## Modules

### 00-options.nix
- Defines all module options
- Service configuration (enable, openFirewall, dataDir)
- Hardware acceleration settings (type, device)
- Media library options (mediaLibraries, watchDownloadsFolder, watchUsername)

### 01-service.nix
- Enables official Jellyfin service
- Adds jellyfin-ffmpeg to system packages
- Configures firewall and data directory

### 02-hardware.nix
- Hardware acceleration packages based on type (vaapi, nvenc, qsv, etc.)
- Adds jellyfin user to video/render groups
- Type-specific package selection

### 03-access.nix
- Media library access and permissions
- Adds jellyfin user to watch user's group
- Sets proper permissions on media directories
- Assertions for configuration validation

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

### Watch Downloads folder for media:

```nix
myServices.jellyfin = {
  enable = true;
  watchDownloadsFolder = true;  # Auto-adds ~/Downloads
  watchUsername = "jason";  # Required when using media libraries
};
```

### Custom media directories (per-host):

```nix
# In hosts/yourhost/configuration.nix
myServices.jellyfin = {
  enable = true;
  watchUsername = "differentuser";
  mediaLibraries = [
    "/mnt/nas/Movies"
    "/mnt/nas/TV"
    "/home/differentuser/Videos"
  ];
};
```

This configuration is **host-specific** - configure different paths for each machine.

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
- `myServices.jellyfin.watchDownloadsFolder` - Auto-add user's Downloads folder (default: false)
- `myServices.jellyfin.watchUsername` - Username for media access (default: `null`, required when using mediaLibraries)
- `myServices.jellyfin.mediaLibraries` - List of custom media directories (default: `[]`)
  - **Configure per-host** in `hosts/yourhost/configuration.nix`
  - Dynamically uses the user's home directory
- `myServices.jellyfin.hardwareAcceleration.enable` - Enable hardware transcoding
- `myServices.jellyfin.hardwareAcceleration.type` - Acceleration type: `vaapi`, `nvenc`, `qsv`, `amf`, `v4l2m2m`, `rkmpp`
- `myServices.jellyfin.hardwareAcceleration.device` - Device path (default: `/dev/dri/renderD128`)

## Setting Up Media Libraries

### Quick Start (Downloads Folder)

1. **Enable in your host configuration:**
   ```nix
   myServices.jellyfin = {
     enable = true;
     watchDownloadsFolder = true;
   };
   ```

2. **Rebuild and access:** `http://localhost:8096`

3. **In Jellyfin web UI:**
   - Complete initial setup
   - **Dashboard** → **Libraries** → **Add Media Library**
   - Path: `/home/jason/Downloads` (or check user's actual home directory)

### Per-Host Custom Paths

**Server 1** (Desktop with NAS):
```nix
# hosts/desktop/configuration.nix
myServices.jellyfin = {
  enable = true;
  mediaLibraries = [ "/mnt/nas/media" "/home/mainuser/Downloads" ];
  watchUsername = "mainuser";
};
```

**Server 2** (Laptop):
```nix
# hosts/laptop/configuration.nix  
myServices.jellyfin = {
  enable = true;
  watchDownloadsFolder = true;
  watchUsername = "laptopuser";
};
```

Each host automatically uses the correct user's home directory.

## Setting Up Media Libraries (old)

After enabling Jellyfin with media directories:

1. **Access Jellyfin web interface:** `http://localhost:8096`

2. **Complete initial setup wizard**

3. **Add Media Library:**
   - Click **Dashboard** → **Libraries** → **Add Media Library**
   - **Content type:** Movies, TV Shows, Music, etc.
   - **Folders:** Click **+** and enter: `/home/jason/Downloads`
   - Click **OK**

4. **Download media to your folder:**
   ```bash
   # Example: Download a movie to ~/Downloads
   cd ~/Downloads
   wget https://example.com/movie.mp4
   ```

5. **Jellyfin will automatically scan and add it to your library**

### Tips:
- Organize by subfolders: `Downloads/Movies`, `Downloads/TV`, etc.
- Use proper file naming for better metadata matching
- Jellyfin rescans periodically, or manually trigger: **Dashboard** → **Scheduled Tasks** → **Scan Media Libraries**

## Options (old, removing)
- `myServices.jellyfin.dataDir` - Data directory (default: `/var/lib/jellyfin`)
- `myServices.jellyfin.hardwareAcceleration.enable` - Enable hardware transcoding
- `myServices.jellyfin.hardwareAcceleration.type` - Acceleration type: `vaapi`, `nvenc`, `qsv`, `amf`, `v4l2m2m`, `rkmpp`
- `myServices.jellyfin.hardwareAcceleration.device` - Device path (default: `/dev/dri/renderD128`)

## Access

After enabling, Jellyfin will be accessible at:
- **Web Interface:** http://localhost:8096

## Client Connection Guide

### Same WiFi / Local Network

When your client device is on the same network as the Jellyfin server:

1. **Find your server's IP address:**
   ```bash
   # On the server, run:
   hostname -I
   # Or: ip addr show
   ```

2. **Connect from client:**
   - **URL:** `http://<SERVER-IP>:8096`
   - **Example:** `http://192.168.1.100:8096`

3. **Automatic discovery:**
   - If `openFirewall = true`, Jellyfin broadcasts via UDP (ports 1900, 7359)
   - Mobile apps can auto-discover the server on the same network
   - Just open the Jellyfin app and it should find your server

### External Network / Public WiFi / Remote Access

To access Jellyfin from outside your home network:

#### Option 1: Port Forwarding (Simple but less secure)

1. **Setup port forwarding on your router:**
   - Forward external port 8096 → internal `<SERVER-IP>:8096`
   - Get your public IP: `curl ifconfig.me`

2. **Connect from anywhere:**
   - **URL:** `http://<YOUR-PUBLIC-IP>:8096`
   - ⚠️ **Security warning:** This exposes your server to the internet

#### Option 2: VPN (Recommended)

1. **Setup WireGuard or Tailscale VPN** on your NixOS server
2. **Connect client to VPN** when away from home
3. **Access via local IP** as if you're on the same network: `http://192.168.1.100:8096`
4. ✅ **Secure:** Traffic is encrypted, server not exposed

#### Option 3: Reverse Proxy with HTTPS (Most secure, requires domain)

1. **Setup Caddy/Nginx** with SSL certificate
2. **Use domain name:** `https://jellyfin.yourdomain.com`
3. ✅ **Secure:** Encrypted traffic, proper authentication
4. Configure in NixOS:
   ```nix
   services.caddy = {
     enable = true;
     virtualHosts."jellyfin.yourdomain.com".extraConfig = ''
       reverse_proxy localhost:8096
     '';
   };
   ```

### Recommended Setup

**For home use:**
- Local network: Direct connection `http://192.168.1.100:8096`
- Remote access: Use VPN (WireGuard/Tailscale)

**For sharing with friends/family:**
- Use reverse proxy with HTTPS and strong authentication
- Consider Jellyfin's user management and parental controls

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
