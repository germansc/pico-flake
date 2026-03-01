# GDB initialization script for Pico 2 W debugging via OpenOCD
#
# ------------------------------------------------------------ OpenOCD Setup

python
import os
iface = os.environ.get("OPENOCD_INTERFACE", "stlink")
gdb.execute(f"set $openocd_interface = \"{iface}\"")
gdb.execute(f'target extended-remote | openocd -f interface/{iface}.cfg -f target/rp2350.cfg -c "adapter speed 4000" -c "gdb_port pipe; log_output openocd.log"')
end

# ----------------------------------------------------------- GDB Settings

# Basic settings
set confirm off
set print pretty on

# -------------------------------------------------------- Target Commands

# Load and break on main.
monitor reset halt
load
break main
continue
