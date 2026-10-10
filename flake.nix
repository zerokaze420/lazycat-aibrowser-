{
  description = "Nix package for LCMD AI Browser";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
      ];
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.callPackage ./default.nix { };
          lzc-ai-browser = self.packages.${system}.default;
        }
      );

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/lzc-ai-browser";
          meta.description = "Run LCMD AI Browser";
        };
      });

      overlays.default = final: prev: {
        lzc-ai-browser = final.callPackage ./default.nix { };
      };

      homeManagerModules.default = import ./hm-module.nix;
    };
}
