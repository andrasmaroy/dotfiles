{
  description = "Personal dotfiles: nix-darwin + home-manager";

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

  outputs = { self, nixpkgs, nix-darwin, home-manager }:
    let
      # Build one nix-darwin system from the shared modules plus a per-host
      # module. Adding a machine = drop a nix/hosts/<name> dir and add a line to
      # darwinConfigurations below.
      mkHost = hostModule:
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
        MC4XN2F3Y3 = mkHost ./nix/hosts/MC4XN2F3Y3;
      };

      # `nix fmt` / CI formatting gate.
      formatter = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-darwin" ]
        (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
    };
}
