/* ***************************************************************************
 *   Project: Pico 2 W Hello World
 *      file: main.c
 *    author: germansc
 *   version: 1.0
 *
 * Simple hello world program for the Raspberry Pi Pico 2 W.
 * Prints a greeting over USB serial and blinks the onboard LED.
 *
 * ************************************************************************* */

#include "pico/cyw43_arch.h"
#include "pico/stdlib.h"

#include <stdio.h>

/**
 * @brief Main entry point.
 *
 * Initializes stdio over USB, initializes the CYW43 wireless chip (which
 * controls the onboard LED on the Pico W), then loops printing a message
 * and toggling the LED every second.
 */
int main(void) {
    stdio_init_all();

    // Initialize the CYW43 driver (required for onboard LED on Pico W/Pico 2 W)
    if (cyw43_arch_init()) {
        printf("CYW43 init failed\n");
        return -1;
    }

    printf("Hello from Pico 2 W!\n");

    bool led_state = false;

    while (true) {
        led_state = !led_state;
        cyw43_arch_gpio_put(CYW43_WL_GPIO_LED_PIN, led_state);
        printf("LED: %s\n", led_state ? "ON" : "OFF");
        sleep_ms(1000);
    }

    return 0;
}
