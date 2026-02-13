# Hosts

Host-specific configurations for each machine.

## Structure

```
hosts/
  └─ dellXps15-9530/
      ├─ configuration.nix          - Machine-specific configuration
      └─ hardware-configuration.nix - Hardware scan results
```

## Machines

### **Dell XPS 15 (9530) - Late 2013** - `dellXps15-9530`


First experimental HomeLab machine.

**Specifications:**
- CPU: Intel Core i7-4702HQ (Haswell)
- GPU: Intel HD Graphics 4600 + NVIDIA GeForce GT 750M (Optimus)
- Display: 15.6" (with touchpad support)
- Desktop: KDE Plasma 6
- Purpose: HomeLab experimentation

**Features:**
- NVIDIA Optimus with legacy driver (470.x for Kepler)
- TLP battery optimization (80% charge threshold)
- Thermal management with thermald
- Dell keyboard backlight persistence
- Custom power profiles for AC/Battery

## Adding a New Host

1. Create a new directory under `hosts/` with the hostname
2. Generate hardware configuration: `nixos-generate-config --dir ./hosts/<hostname>`
3. Create `configuration.nix` with machine-specific settings
4. Add the host to `flake.nix` in `nixosConfigurations`
5. Import common modules as needed
