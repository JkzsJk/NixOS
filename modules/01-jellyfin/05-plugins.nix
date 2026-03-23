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
      version = "20.0.0.0"; # e.g. "20.0.0.0" — check: https://github.com/jellyfin/jellyfin-plugin-tvdb/releases/latest
      url     = "https://github.com/jellyfin/jellyfin-plugin-tvdb/releases/download/v20/thetvdb_20.0.0.0.zip"; # e.g. "https://github.com/jellyfin/jellyfin-plugin-tvdb/releases/download/v20/thetvdb_20.0.0.0.zip"
      sha256  = "0qzkkb0lwb4d5fafr6xykzz6rhxrgrjn6pvp64vml8ys0fib65vd"; # replace with output of: nix-prefetch-url --type sha256 <url>
    }
    {
      name    = "intro-skipper";
      version = "1.10.11.16"; # e.g. "10.10.3.0" — check: https://github.com/intro-skipper/intro-skipper/releases/latest
      url     = "https://github.com/intro-skipper/intro-skipper/releases/download/10.11%2Fv1.10.11.16/intro-skipper-v1.10.11.16.zip"; # e.g. "https://github.com/intro-skipper/intro-skipper/releases/download/10.11%2Fv1.10.11.16/intro-skipper-v1.10.11.16.zip"
      sha256  = "0437xg96yzwq63pwdif4qlz2g95gs1pcy28xjr9b6k3sn2v43p45"; # replace with output of: nix-prefetch-url --type sha256 <url>
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
