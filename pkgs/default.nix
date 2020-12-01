{ pkgs ? import <nixpkgs> {} }:
let self = {
  lightning-charge = pkgs.callPackage ./lightning-charge { };
  nanopos = pkgs.callPackage ./nanopos { };
  spark-wallet = pkgs.callPackage ./spark-wallet { };
  electrs = pkgs.callPackage ./electrs { };
  elementsd = pkgs.callPackage ./elementsd { withGui = false; };
  hwi = pkgs.callPackage ./hwi { };
  liquid-swap = pkgs.python3Packages.callPackage ./liquid-swap { };
  joinmarket = pkgs.callPackage ./joinmarket { inherit (self) nbPython3Packages; };
  generate-secrets = pkgs.callPackage ./generate-secrets { };
  nixops19_09 = pkgs.callPackage ./nixops { };
  netns-exec = pkgs.callPackage ./netns-exec { };
  lightning-loop = pkgs.callPackage ./lightning-loop { };
  extra-container = pkgs.callPackage ./extra-container { };
  clightning-plugins = import ./clightning-plugins pkgs self.nbPython3Packages;

  nbPython3Packages = (pkgs.python3.override {
    packageOverrides = pySelf: super: import ./python-packages self pySelf;
  }).pkgs;

  pinned = import ./pinned.nix;

  lib = import ./lib.nix { inherit (pkgs) lib; };

  modulesPkgs = self // self.pinned;

  # Used in ../.travis.yml
  clightning-plugins-all = pkgs.writeText "clightning-plugins"
    (pkgs.lib.concatMapStringsSep "\n" toString (builtins.attrValues self.clightning-plugins));
}; in self
