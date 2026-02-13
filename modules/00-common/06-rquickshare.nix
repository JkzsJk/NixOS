# RQuickShare configuration
{ config, pkgs, lib, ... }:

{
  # Wrap rquickshare with environment variable
  nixpkgs.config.packageOverrides = pkgs: {
    rquickshare = pkgs.symlinkJoin {
      name = "rquickshare-wrapped";
      paths = [ pkgs.rquickshare ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/rquickshare \
          --set WEBKIT_DISABLE_COMPOSITING_MODE 1
      '';
    };
  };

  # Open firewall ports for RQuickShare
  networking.firewall = {
    allowedTCPPorts = [ 
      19550  # RQuickShare web interface
    ];
    allowedUDPPorts = [ 
      5353   # mDNS for device discovery
    ];
    
    # Allow mDNS for local network discovery
    allowedUDPPortRanges = [
      { from = 5353; to = 5353; }
    ];
  };
}
