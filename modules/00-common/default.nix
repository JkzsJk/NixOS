# Shared configuration across all hosts
{ config, pkgs, inputs, ... }:

{
  imports = [
    ./01-packages.nix
    ./02-shell.nix
    ./03-system.nix
    ./04-vivaldi.nix
    ./05-rquickshare.nix
    ./06-localsend.nix
  ];
}
