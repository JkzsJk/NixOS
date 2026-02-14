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

  # Configure static port for RQuickShare (per-user config)
  home-manager.sharedModules = [
    ({ config, ... }: {
      home.file.".local/share/dev.mandre.rquickshare/.settings.json" = {
        text = builtins.toJSON {
          port = 65535;
          startMinimised = true;
          downloadPath = "${config.home.homeDirectory}/Downloads";
        };
        force = true;  # Overwrite existing settings file
      };
    })
  ];

  # Open firewall ports for RQuickShare
  networking.firewall = {
    allowedTCPPorts = [ 
      65535  # RQuickShare with static port
    ];
    allowedUDPPorts = [ 
      5353   # mDNS for device discovery
    ];
  };
}
