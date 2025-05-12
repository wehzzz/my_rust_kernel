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
            { mkShell, pkg-config, zlib, gcc, glibc, flex, bison, openssl, qemu }:
            mkShell {
              # What to use for what ?
              # See https://github.com/NixOS/nixpkgs/pull/50881#issuecomment-440772499

              nativeBuildInputs = [ flex bison pkg-config openssl ];
              depsBuildBuild = [ gcc qemu ];
              # glibc.static is needed to get static libraries (like -lm) for linker
              buildInputs = [ zlib glibc.static openssl ];
            }
          )
          { };
    };
}
