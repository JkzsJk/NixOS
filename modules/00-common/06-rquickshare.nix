# RQuickShare configuration
{ config, pkgs, lib, ... }:

let
  rquicksharePort = 65535;  # Maximum available port number
in
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

  # Configure static port for RQuickShare (per-user config)
  home-manager.sharedModules = [
    {
      home.file.".local/share/dev.mandre.rquickshare/.settings.json".text = builtins.toJSON {
        port = rquicksharePort;
      };
    }
  ];

  # Open firewall ports for RQuickShare
  networking.firewall = {
    allowedTCPPorts = [ 
      rquicksharePort  # RQuickShare with static port
    ];
    allowedUDPPorts = [ 
      5353   # mDNS for device discovery
    ];
  };
}
