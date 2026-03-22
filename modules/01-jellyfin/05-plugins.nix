# Jellyfin plugins — declaratively installed via activation script.
# Plugins are fetched at build time (pinned to specific release versions)
# and unpacked into Jellyfin's plugin directory on system activation.
#
# To add or update a plugin:
#   1. Find the release zip URL on GitHub (releases page)
#   2. Get the hash: nix-prefetch-url --type sha256 <url>
#   3. Update the url, version, and sha256 below
#   4. nixos-rebuild switch
#
# Plugin directory layout Jellyfin expects:
#   $dataDir/plugins/<PluginName>_<version>/  ← one folder per version
#     *.dll
#     meta.json
{ config, lib, pkgs, ... }:

with lib;

let
  dataDir = config.myServices.jellyfin.dataDir;

  # ── Plugin definitions ──────────────────────────────────────────────────────
  # Each entry: { name, version, url, sha256 }
  # name    = folder prefix Jellyfin uses (must match what the zip extracts as)
  # version = version string (used to detect if already installed)
  # url     = direct download URL to the release zip
  # sha256  = run: nix-prefetch-url --type sha256 <url>

  plugins = [
    {
      name    = "TVDBPlugin";
      version = ""; # e.g. "5.0.0.0" — check: https://github.com/jellyfin/jellyfin-plugin-tvdb/releases/latest
      url     = ""; # e.g. "https://github.com/jellyfin/jellyfin-plugin-tvdb/releases/download/v5.0.0/tvdb_5.0.0.0.zip"
      sha256  = lib.fakeHash; # replace with output of: nix-prefetch-url --type sha256 <url>
    }
    {
      name    = "intro-skipper";
      version = ""; # e.g. "10.10.3.0" — check: https://github.com/intro-skipper/intro-skipper/releases/latest
      url     = ""; # e.g. "https://github.com/intro-skipper/intro-skipper/releases/download/10.10.3.0/intro-skipper-10.10.3.0.zip"
      sha256  = lib.fakeHash; # replace with output of: nix-prefetch-url --type sha256 <url>
    }
  ];

  # ── Installation helper ─────────────────────────────────────────────────────
  mkPluginSrc = { url, sha256, ... }: pkgs.fetchurl { inherit url sha256; };

  installPlugin = plugin:
    let src = mkPluginSrc plugin;
    in ''
      pluginDir="${dataDir}/plugins/${plugin.name}_${plugin.version}"
      if [ ! -d "$pluginDir" ]; then
        # Remove any older installed versions of this plugin first
        rm -rf "${dataDir}/plugins/${plugin.name}_"*
        mkdir -p "$pluginDir"
        ${pkgs.unzip}/bin/unzip -o ${src} -d "$pluginDir"
        chown -R jellyfin:jellyfin "$pluginDir"
        echo "Installed Jellyfin plugin: ${plugin.name} ${plugin.version}"
      fi
    '';

in
{
  config = mkIf config.myServices.jellyfin.enable {
    system.activationScripts.jellyfinPlugins = stringAfter [ "users" "groups" ] ''
      mkdir -p "${dataDir}/plugins"
      chown jellyfin:jellyfin "${dataDir}/plugins"

      ${concatMapStrings installPlugin plugins}
    '';
  };
}
