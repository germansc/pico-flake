# Pico 2 W Template

Firmware project template for the **Raspberry Pi Pico 2 W** (RP2350,
ARM Cortex-M33) using the official Pico SDK and a Nix-based development
environment.

```
.
├── docs/
├── src/
│   └── main.c
├── templates/
│   ├── module.c
│   ├── module.h
│   └── test_module.c
├── test/
│   ├── Makefile
│   ├── project.yml
│   └── tests/
├── tools/
├── .github/
├── .gitlab-ci.yml
├── .clang-format
├── CMakeLists.txt
├── pico_sdk_import.cmake
├── flake.nix
├── Makefile
└── Readme.md
```

* **src/** — Firmware source code. `main.c` is the entry point.
* **templates/** — Template files for the module generator (`make module`).
* **test/** — Ceedling-based unit test infrastructure.
* **docs/** — Project documentation.
* **tools/** — Build scripts and third-party tools.
* **CMakeLists.txt** — Pico SDK CMake configuration (board, platform, libraries).
* **pico_sdk_import.cmake** — Pico SDK bootstrap script.
* **Makefile** — CMake wrapper providing common Make targets.


## Development Environment

This project uses [Nix](https://nixos.org/) to provide a reproducible
development environment. The `flake.nix` file declares all required
dependencies, so all developers and CI pipelines use the exact same
toolchain.

To enter the development shell:

```
nix develop
```

The shell provides:

* **Pico SDK** (with submodules: TinyUSB, cyw43-driver, lwIP)
* **ARM Toolchain:** gcc-arm-embedded
* **Build System:** CMake, GNU Make
* **Flash Tool:** picotool
* **Static Analysis:** clang-format, clang-tidy, cppcheck
* **Unit Testing:** Ceedling (with CMock and Unity)
* **Code Coverage:** gcovr
* **Host Compiler:** GCC (needed by pioasm/elf2uf2 during SDK build)


## Building and Flashing

From inside the development shell (`nix develop`):

```sh
# Configure and build the firmware
make build

# Clean and rebuild from scratch
make rebuild

# Flash to a connected Pico (reboots into BOOTSEL automatically)
make flash
```

The build produces a UF2 file at `build/pico-sdk.uf2`.

For more info on available targets:

```
make help
```

### USB Permissions

`picotool` requires access to the Pico's USB device. Without proper udev
rules, `make flash` will fail with a permissions error. To fix this, create
a udev rule:

```sh
sudo tee /etc/udev/rules.d/99-picotool.rules << 'EOF'
# Raspberry Pi RP2350 - BOOTSEL mode
SUBSYSTEM=="usb", ATTR{idVendor}=="2e8a", ATTR{idProduct}=="000f", MODE="0666", GROUP="plugdev"
# Raspberry Pi RP2350 - Application mode (USB serial)
SUBSYSTEM=="usb", ATTR{idVendor}=="2e8a", ATTR{idProduct}=="0009", MODE="0666", GROUP="plugdev"
# Catch-all for Raspberry Pi USB devices
SUBSYSTEM=="usb", ATTR{idVendor}=="2e8a", MODE="0666", GROUP="plugdev"
EOF

sudo udevadm control --reload-rules
sudo udevadm trigger
```

After this, unplug and re-plug the Pico. `make flash` should work without
issues. Make sure your user is in the `plugdev` group (`groups` to check,
`sudo usermod -aG plugdev $USER` to add).


## Module Generator

New source modules can be scaffolded using the module generator:

```
make module src/path/modulename
```

This creates:
* `src/path/modulename.c` — source file
* `src/path/modulename.h` — header file
* `test/tests/path/test_modulename.c` — unit test file

The generated files are populated from the templates in the `templates/`
directory. New modules must be added to `CMakeLists.txt` manually.


## Testing

Unit tests are managed using Ceedling. To run the full test suite:

```
make test
```


## USB Serial Output

The firmware is configured for **USB CDC** (serial over USB). To see
output, connect to the Pico's USB serial port after flashing:

```sh
# Linux (device path may vary)
screen /dev/ttyACM0 115200
```

UART stdio is disabled by default. This can be changed in `CMakeLists.txt`


## Board Configuration

| Setting        | Value          |
|----------------|----------------|
| Board          | `pico2_w`      |
| Platform       | `rp2350-arm-s` |
| Chip           | RP2350         |
| Core           | ARM Cortex-M33 |
| Wireless       | CYW43          |
| Onboard LED    | Via CYW43 GPIO |

## License

This project is licensed under the MIT License.
