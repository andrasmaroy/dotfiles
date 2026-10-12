{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
    }:
    let
      mkHost =
        hostModule:
        nix-darwin.lib.darwinSystem {
          modules = [
            ./nix/darwin
            home-manager.darwinModules.home-manager
            hostModule
          ];
        };
    in
    {
      darwinConfigurations = {
        Andrass-MacBook-Pro = mkHost ./nix/hosts/Andrass-MacBook-Pro;
        MC4XN2F3Y3 = mkHost ./nix/hosts/MC4XN2F3Y3;
      };

      formatter = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-darwin" ] (
        system: nixpkgs.legacyPackages.${system}.nixfmt-tree
      );
    };
}
