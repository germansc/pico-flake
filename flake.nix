{
  description = "Raspberry Pi Pico 2 W development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Pico SDK with all submodules (TinyUSB, cyw43-driver, lwIP, etc.)
        pico-sdk-full = pkgs.pico-sdk.override { withSubmodules = true; };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            # Pico SDK and toolchain
            pico-sdk-full
            pkgs.gcc-arm-embedded
            pkgs.cmake
            pkgs.gnumake
            pkgs.python3
            pkgs.picotool

            # Native host toolchain (needed by pico-sdk build for pioasm/elf2uf2)
            pkgs.gcc

            # Static Analysis & Formatting
            pkgs.clang-tools
            pkgs.cppcheck

            # Unit Testing (Ceedling + dependencies)
            pkgs.ceedling

            # Code Coverage
            pkgs.gcovr
          ];

          # Point CMake at the Nix-provided Pico SDK
          PICO_SDK_PATH = "${pico-sdk-full}/lib/pico-sdk";

          shellHook = ''
            echo "Pico 2 W Development Environment"
            echo "================================="
            echo "Pico SDK:  ${pico-sdk-full.version}"
            echo "Toolchain: $(arm-none-eabi-gcc --version | head -n1)"
            echo "CMake:     $(cmake --version | head -n1)"
            echo "Picotool:  $(picotool version 2>/dev/null | head -n1)"
            echo ""
            echo "Run 'make help' for available targets"
          '';
        };
      }
    ) // {
      templates.default = {
        path = ./.;
        description = "Raspberry Pi Pico 2 W development environment";
      };
    };
}
