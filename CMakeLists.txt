cmake_minimum_required(VERSION 3.13)

# Set the board and platform BEFORE importing the SDK
set(PICO_BOARD pico2_w)
set(PICO_PLATFORM rp2350-arm-s)

# Import the Pico SDK (reads PICO_SDK_PATH from env or cmake cache)
include(pico_sdk_import.cmake)

project(pico-sdk C CXX ASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

# Initialize the SDK (must be called after project())
pico_sdk_init()

# ----------------------------------------------------------------------- Main
add_executable(${PROJECT_NAME}
    src/main.c
)

# Pull in common dependencies
target_link_libraries(${PROJECT_NAME}
    pico_stdlib
    pico_cyw43_arch_none     # CYW43 driver (needed for onboard LED on Pico W)
)

# Enable USB output, disable UART output for stdio
pico_enable_stdio_usb(${PROJECT_NAME} 1)
pico_enable_stdio_uart(${PROJECT_NAME} 0)

# Generate UF2, hex, map, bin outputs in addition to ELF
pico_add_extra_outputs(${PROJECT_NAME})
