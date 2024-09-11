{
  description = "A flake for developing lua applications";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    inputs:
    inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import inputs.nixpkgs { inherit system; };

        utilities = with pkgs; [
          stylua
          lua-language-server
        ];
      in
      {
        devShells =
          let
            util = pkgs.mkShell { packages = utilities; };
            battery = pkgs.mkShell { packages = utilities; };
            chain = null;
          in
          {
            inherit battery chain util;
            default = battery;
          };
      }
    );
}
