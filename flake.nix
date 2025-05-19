{
  description = "My pikaboot build env";

  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  outputs = { self, nixpkgs }:
    let pkgs = import nixpkgs {
      system = "x86_64-linux";
      crossSystem = {
        config = "aarch64-linux-gnu";
      };
    };
    in
    {
      devShell.x86_64-linux =
        pkgs.callPackage
          (
            { mkShell, qemu }:
            mkShell {
              # What to use for what ?
              # See https://github.com/NixOS/nixpkgs/pull/50881#issuecomment-440772499

              nativeBuildInputs = [ ];
              depsBuildBuild = [ qemu ];
              # glibc.static is needed to get static libraries (like -lm) for linker
              buildInputs = [ ];
            }
          )
          { };
    };
}
